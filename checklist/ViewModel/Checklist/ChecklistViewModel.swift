//
//  CreateChecklistViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 19/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import PromiseKit


class ChecklistViewModel: ObservableObject {
    
    @Published var shouldCreateChecklistName: Bool = true {
        didSet {
            shouldDisplayAddItems = !shouldCreateChecklistName
        }
    }
    @Published var shouldDisplayAddItems: Bool = false
    @Published var shouldDismissView: Bool = false
    @Published var isReminderOn: Bool = false {
        didSet {
            guard isReminderOn else {
                return
            }
            self.notificationManager.registerPushNotifications()
                .done { granted  in
                    if !granted {
                        self.isReminderOn = false
                        self.alert = .notificationsDisabled
                    }
                }
                .catch { log(error: $0.localizedDescription) }
        }
    }
    @Published var reminderDate: Date = Date()
    @Published var isCreateTemplateChecked: Bool = false
    var shouldDisplaySetReminder: Bool { viewState.isEditEnabled && !shouldCreateChecklistName }
    var shouldDisplaySaveAsTemplate: Bool { viewState.isCreateNew && !shouldCreateChecklistName }
    var shouldDisplayActionButton: Bool { viewState.isEditEnabled && !shouldCreateChecklistName }
    var shouldDisplayDescription: Bool { viewState.isEditEnabled || !checklistDescription.isEmpty }
    var isEditable: Bool { viewState.isEditEnabled }
    
    @Published var checklistName: String = ""
    @Published var checklistDescription: String = ""
    var items: [ChecklistItemViewModel] = []
    
    @Published var viewState: ChecklistViewState
    @Published var alertVisibility = ViewVisibility(view: ChecklistAlert.none.view)
    @Published var sheetVisibility = ViewVisibility(view: AnyView(EmptyView()))
    @Published var actionSheetVisibility = ViewVisibility(view: ChecklistActionSheet.none.view)
    private var alert: ChecklistAlert = .none {
        didSet {
            alertVisibility.set(view: alert.view, isVisible: alert.isVisible)
        }
    }
    private var actionSheet: ChecklistActionSheet = .none {
        didSet {
            actionSheetVisibility.set(view: actionSheet.view, isVisible: actionSheet.isVisible)
        }
    }
    
    let onCreateTitleNext: EmptySubject = .init()
    let onAddItemsNext: EmptySubject = .init()
    let onDeleteItem: PassthroughSubject<ChecklistItemViewModel, Never> = .init()
    let onEditTapped: EmptySubject = .init()
    let onDoneTapped: EmptySubject = .init()
    let onActionButtonTapped: EmptySubject = .init()
    let onDismissTapped: EmptySubject = .init()
    
    let checklistDataSource: ChecklistDataSource
    let templateDataSource: TemplateDataSource
    let notificationManager: NotificationManager
    lazy var navBarViewModel: ChecklistNavBarViewModel = {
        let viewModel = AppContext.resolver.resolve(
            ChecklistNavBarViewModel.self,
            argument: currentChecklist.eraseToAnyPublisher()
        )!
        viewModel.backButton.didTap.subscribe(onDismissTapped).store(in: &cancellables)
        viewModel.actionsButton.didTap.sink { [weak self] in
            guard let self = self else { return }
            self.actionSheet = .actionMenu(delegate: self)
            self.objectWillChange.send()
        }.store(in: &cancellables)
        viewModel.doneButton.didTap.sink { [weak self] in
            withAnimation {
                self?.navBarViewModel.shouldDisplayDoneButton = false
                self?.onDoneTapped.send()
            }
        }.store(in: &cancellables)
        return viewModel
    }()
    
    var cancellables =  Set<AnyCancellable>()
    var onDismiss: EmptyPublisher {
        onDismissTapped.eraseToAnyPublisher()
    }
    var isNavBarVisible: Bool {
        currentChecklist.value != nil
    }
    private var currentChecklist: ChecklistCurrentValueSubject
    
    init(
        viewState: ChecklistViewState,
        checklistDataSource: ChecklistDataSource,
        templateDataSource: TemplateDataSource,
        notificationManager: NotificationManager
    ) {
        self.checklistDataSource = checklistDataSource
        self.templateDataSource = templateDataSource
        self.notificationManager = notificationManager
        self.viewState = viewState
        self.currentChecklist = .init(viewState.checklist)
        
        if let template = viewState.template {
            setupTemplate(template)
        } else if viewState.isDisplay {
            setupDisplayChecklist()
        }
        
        onCreateTitleNext.sink { [weak self] in
            self?.setupItemsAndFinalizeView()
            self?.shouldCreateChecklistName = false
        }.store(in: &cancellables)
        
        onDeleteItem.sink { [weak self] item in
            self?.items.removeAll { $0.id == item.id }
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        onEditTapped.sink { [weak self] in
            guard
                let self = self,
                let checklist = self.currentChecklist.value
            else {
                return
            }
            self.items.forEach { $0.isEditable = true }
            self.isReminderOn = checklist.isValidReminderSet
            self.reminderDate = checklist.reminderDate ?? Date()
            self.viewState = .update(checklist: checklist)
        }.store(in: &cancellables)
        
        onDoneTapped.sink { [weak self] in
            self?.setEditDoneAndUpdateChecklist()
        }.store(in: &cancellables)
        
        onActionButtonTapped.sink { [weak self] in
            guard let self = self else { return }
            if self.viewState.isUpdate {
                self.setEditDoneAndUpdateChecklist()
            } else {
                self.saveNewChecklist()
            }
        }.store(in: &cancellables)
    }
}


// MARK: - Private methods

private extension ChecklistViewModel {
    
    func setEditDoneAndUpdateChecklist() {
        guard let checklist = self.currentChecklist.value else {
            return
        }
        self.items.forEach { $0.isEditable = false }
        self.resignFirstResponder()
        self.updateChecklist()
        self.viewState = .display(checklist: checklist)
    }
    
    func setupDisplayChecklist() {
        guard let checklist = currentChecklist.value else {
            return
        }
        shouldCreateChecklistName = false
        self.checklistName = checklist.title
        self.checklistDescription = checklist.description ?? ""
        checklist.items.forEach { self.addNewItem($0) }
    }
    
    func saveNewChecklist() {
        let checklist = self.getChecklistFromUI()
        if isReminderOn {
            self.notificationManager.setupReminder(for: checklist)
                .done {
                    self.createChecklist(checklist, shouldCreateTemplate: self.isCreateTemplateChecked)
                    self.shouldDismissView = true
                }
                .catch {
                    log(error: $0.localizedDescription)
                }
        } else {
            self.createChecklist(checklist, shouldCreateTemplate: isCreateTemplateChecked)
            self.shouldDismissView = true
        }
    }
    
    func updateChecklist() {
        guard let checklist = currentChecklist.value else {
            log(warning: "Can not update checklist: checklist not found")
            return
        }
        let checklistToUpdate = getChecklistFromUI(id: checklist.id)
        if checklist.reminderDate != checklistToUpdate.reminderDate {
            notificationManager.removeReminder(for: checklist)
        }
        firstly {
            .value(checklistToUpdate.isValidReminderSet)
        }.then { isReminderSet -> Promise<Void> in
            guard isReminderSet else {
                return .value
            }
            return self.notificationManager.setupReminder(for: checklistToUpdate)
        }.then {
            self.checklistDataSource.updateChecklist(checklistToUpdate)
        }.done {
            log(debug: "Update checklist success. \(checklistToUpdate)")
        }.catch { error in
            log(error: "Update checklist failed. \(error.localizedDescription)")
        }
    }
    
    func setupItemsAndFinalizeView() {
        if items.isEmpty {
            addNewItem(name: nil, isDone: false, isEditable: true)
        } else if let lastItem = items.last, !lastItem.name.isEmpty {
            addNewItem(name: nil, isDone: false, isEditable: true)
        }
        let emptyItems = items.filter{ $0.name.isEmpty && $0 != items.last }
        emptyItems.forEach { emptyItem in
            items.removeAll { emptyItem == $0 }
        }
    }
    
    func addNewItem(name: String?, isDone: Bool, isEditable: Bool) {
        let id = UUID().uuidString
        let viewModel = ChecklistItemViewModel(id: id, name: name, isDone: isDone, isEditable: isEditable)
        viewModel.onNameChanged.sink { [weak self] name in
            self?.setupItemsAndFinalizeView()
        }.store(in: &cancellables)
        self.items.append(viewModel)
        self.objectWillChange.send()
    }
    
    func addNewItem(_ item: ChecklistItemDataModel) {
        let subject = CurrentValueSubject<ChecklistItemDataModel, Never>(item)
        let viewModel = ChecklistItemViewModel(item: subject)
        
        subject.dropFirst().sink { [weak self] item in
            guard
                let self = self,
                let checklist = self.currentChecklist.value
            else {
                return
            }
            self.checklistDataSource.updateItem(item, in: checklist)
                .catch { $0.log(message: "Failed to update checklist item \(item)") }
        }.store(in: &cancellables)
        
        self.items.append(viewModel)
        self.objectWillChange.send()
    }
    
    func setupTemplate(_ template: TemplateDataModel) {
        checklistName = template.title
        template.items.forEach { self.addNewItem(name: $0.name, isDone: false, isEditable: true) }
        addNewItem(name: nil, isDone: false, isEditable: true)
        shouldCreateChecklistName = false
    }
    
    func getChecklistFromUI(id: String? = nil) -> ChecklistDataModel {
        ChecklistDataModel(
            id: id ?? UUID().uuidString,
            title: self.checklistName,
            description: self.checklistDescription,
            updateDate: Date(),
            reminderDate: reminderDate,
            items: self.items.compactMap {
                guard !$0.name.isEmpty else {
                    return nil
                }
                return ChecklistItemDataModel(
                    id: $0.id,
                    name: $0.name,
                    isDone: $0.isDone,
                    updateDate: $0.updateDate
                )
            }
        )
    }
    
    func createChecklist(_ checklist: ChecklistDataModel, shouldCreateTemplate: Bool) {
        checklistDataSource.createChecklist(checklist)
            .then { _ -> Promise<Void> in
                guard shouldCreateTemplate else {
                    return .value
                }
                return self.templateDataSource.createTemplate(
                    .init(
                        id: UUID().uuidString,
                        title: self.checklistName,
                        description: self.checklistDescription,
                        items: self.items.compactMap {
                            guard !$0.name.isEmpty else {
                                return nil
                            }
                            return ChecklistItemDataModel(
                                id: $0.id,
                                name: $0.name,
                                isDone: false,
                                updateDate: Date()
                            )
                        }
                    )
                )
            }
            .catch {
                $0.log(message: "Failed to create template")
                #warning("TODO(): Implement proper error handling")
            }
    }
    
    #if canImport(UIKit)
    func resignFirstResponder() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    #endif
}


extension ChecklistViewModel: ChecklistActionSheetDelegate {
    
    func onEditAction() {
        withAnimation {
            navBarViewModel.shouldDisplayDoneButton = true
            onEditTapped.send()
        }
    }
    
    func onMarkAllDoneAction() {
        alert = .confirmMarkAllDone(onConfirm: { [weak self] in
            guard let self = self else { return }
            self.items.forEach { item in
                item.isDone = true
            }
            self.updateChecklist()
        })
    }
    
    func onSetReminderAction() {
        guard let checklist = currentChecklist.value else {
            return
        }
        let viewModel = AppContext.resolver.resolve(EditReminderViewModel.self, argument: checklist)!
        viewModel.onDeleteReminder.sink { [weak self] in
            self?.sheetVisibility.isVisible = false
            self?.checklistDataSource.updateReminderDate(nil, for: checklist).done {
                self?.notificationManager.removeReminder(for: checklist)
                self?.currentChecklist.value?.reminderDate = nil
            }.catch { error in
                error.log(message: "Failed to delete reminder")
                #warning("TODO: Add error hanling")
            }
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        viewModel.onSaveReminder.sink { [weak self] date in
            guard let self = self else { return }
            self.sheetVisibility.isVisible = false
            firstly {
                self.checklistDataSource.updateReminderDate(date, for: checklist)
            }.get {
                self.currentChecklist.value?.reminderDate = date
            }.then { _ -> Promise<Void> in
                guard let checklist = self.currentChecklist.value else {
                    throw DataSourceError.checkListNotFound
                }
                return self.notificationManager.setupReminder(for: checklist)
            }.catch { error in
                error.log(message: "Failed to save reminder")
                #warning("TODO: Add error hanling")
            }
            self.objectWillChange.send()
        }.store(in: &cancellables)
        let view = EditReminderView(viewModel: viewModel)
        sheetVisibility.set(view: AnyView(view), isVisible: true)
    }
    
    func onSaveAsTemplateAction() {
        
    }
    
    func onDeleteAction() {
        alert = .confirmDelete(onDelete: { [weak self] in
            guard let checklist = self?.currentChecklist.value else {
                return
            }
            self?.checklistDataSource.deleteChecklist(checklist)
                .done { self?.onDismissTapped.send() }
                .catch { error in
                    #warning("TODO: Add error handling")
                }
        })
    }
}
