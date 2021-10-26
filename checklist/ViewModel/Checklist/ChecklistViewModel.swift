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
    
    @Published var shouldDisplayAddItems: Bool = true
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
    var shouldDisplaySetReminder: Bool {
        viewState.isEditEnabled && !viewState.isCreateTemplate && !viewState.isUpdateTemplate
    }
    var shouldDisplaySaveAsTemplate: Bool { viewState.isCreateNew }
    var shouldDisplayActionButton: Bool { viewState.isEditEnabled }
    var shouldDisplayDescription: Bool { viewState.isEditEnabled || !checklistDescription.isEmpty }
    
    @Published var isEditable: Bool
    @Published var checklistName: String = ""
    @Published var checklistDescription: String = ""
    var items: [ChecklistItemViewModel] = []
    var navigationDestinationView = AnyView(EmptyView())
    @Published var isNavigationLinkActive = false
    
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
    private let didCreateTemplateSubject = EmptySubject()
    private let didUpdateTemplate = EmptySubject()
    
    let createChecklistNavbarViewModel: BackButtonNavBarViewModel = {
        let vm = BackButtonNavBarViewModel(title: "Create Checklist")
        vm.isBackButtonHidden = true
        vm.style = .big
        return vm
    }()
    let onAddItemsNext: EmptySubject = .init()
    let onDeleteItem: PassthroughSubject<ChecklistItemViewModel, Never> = .init()
    let onEditTapped: EmptySubject = .init()
    let onDoneTapped: EmptySubject = .init()
    let onActionButtonTapped: EmptySubject = .init()
    let onDismissTapped: EmptySubject = .init()
    var onDidCreateTemplate: EmptyPublisher {
        didCreateTemplateSubject.eraseToAnyPublisher()
    }
    var onDidUpdateTemplate: EmptyPublisher {
        didUpdateTemplate.eraseToAnyPublisher()
    }
    
    let reminderCheckboxViewModel: CheckboxViewModel
    let saveAsTemplateCheckboxViewModel: CheckboxViewModel
    let checklistDataSource: ChecklistDataSource
    let templateDataSource: TemplateDataSource
    let notificationManager: NotificationManager
    let restrictionManager: RestrictionManager
    
    lazy var navBarViewModel: ChecklistNavBarViewModel = {
        let viewModel = AppContext.resolver.resolve(
            ChecklistNavBarViewModel.self,
            argument: currentChecklist.eraseToAnyPublisher()
        )!
        viewModel.backButton.didTap.subscribe(onDismissTapped).store(in: &cancellables)
        viewModel.actionsButton.didTap.zip(currentChecklist).sink { [weak self] tupple in
            guard let self = self, let checklist = tupple.1  else {
                return
            }
            self.actionSheet = .actionMenu(checklist: checklist, delegate: self)
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
        !viewState.isCreateTemplate && currentChecklist.value != nil
    }
    private var currentChecklist: ChecklistCurrentValueSubject
    
    
    init(
        viewState: ChecklistViewState,
        checklistDataSource: ChecklistDataSource,
        templateDataSource: TemplateDataSource,
        notificationManager: NotificationManager,
        restrictionManager: RestrictionManager
    ) {
        self.checklistDataSource = checklistDataSource
        self.templateDataSource = templateDataSource
        self.notificationManager = notificationManager
        self.restrictionManager = restrictionManager
        self.viewState = viewState
        self.currentChecklist = .init(viewState.checklist)
        self.reminderCheckboxViewModel = .init(
            title: "Remind me on this device",
            isChecked: viewState.checklist?.isValidReminderSet ?? false
        )
        self.saveAsTemplateCheckboxViewModel = .init(title: "Save as template", isChecked: false)
        self.isEditable = viewState.isEditEnabled
        
        if viewState.isCreateNew {
            addNewItem(name: nil, isDone: false, isEditable: true)
        }
        
        reminderCheckboxViewModel.checked.sink { [weak self] isChecked in
            withAnimation {
                self?.isReminderOn = isChecked
            }
        }.store(in: &cancellables)
        
        saveAsTemplateCheckboxViewModel.checked.sink { [weak self] isChecked in
            withAnimation {
                self?.isCreateTemplateChecked = isChecked
            }
        }.store(in: &cancellables)
        
        if let template = viewState.template {
            setupTemplate(template)
        } else if viewState.isCreateTemplate {
            setupCreateTemplate()
        } else if viewState.isDisplay || viewState.isUpdate {
            setupDisplayChecklist(isUpdate: viewState.isUpdate)
        }
        
        onDeleteItem.sink { [weak self] item in
            self?.items.removeAll { $0.id == item.id }
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        onEditTapped.sink { [weak self] in
            self?.enableEditMode()
        }.store(in: &cancellables)
        
        onDoneTapped.sink { [weak self] in
            self?.setEditDoneAndUpdateChecklist()
        }.store(in: &cancellables)
        
        onActionButtonTapped.sink { [weak self] in
            guard let self = self else { return }
            switch self.viewState {
            case .update:
                self.setEditDoneAndUpdateChecklist()
            case .createFromTemplate, .createNew:
                self.saveNewChecklist()
            case .createTemplate:
                self.createTemplate(self.getChecklistFromUI())
            case .updateTemplate:
                self.updateTemplate()
            default:
                break
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
        self.isEditable = false
        self.resignFirstResponder()
        self.updateChecklist()
        self.viewState = .display(checklist: checklist)
    }
    
    func setupDisplayChecklist(isUpdate: Bool) {
        guard let checklist = currentChecklist.value else {
            return
        }
        self.checklistName = checklist.title
        self.checklistDescription = checklist.description ?? ""
        checklist.items.forEach { self.addNewItem($0) }
        checklistDataSource.updateChecklist(
            checklist.getWithCurrentUpdateDate()
        ).catch { error in
            error.log(message: "Failed to update checklist")
        }
        if isUpdate {
            enableEditMode()
        }
    }
    
    func setupCreateTemplate() {
        guard let checklist = currentChecklist.value else {
            return
        }
        self.checklistName = checklist.title
        self.checklistDescription = checklist.description ?? ""
        checklist.items.forEach { addNewItem(name: $0.name, isDone: false, isEditable: true) }
        addNewItem(name: nil, isDone: false, isEditable: true)
    }
    
    func saveNewChecklist() {
        let checklist = self.getChecklistFromUI()
        restrictionManager.verifyCreateChecklist(presenter: self).get { verified  in
            guard verified else {
                return
            }
            if self.isReminderOn, let date = checklist.reminderDate {
                self.notificationManager.setupReminder(date: date, for: checklist)
                    .done {
                        self.createChecklist(checklist, shouldCreateTemplate: self.isCreateTemplateChecked)
                        self.shouldDismissView = true
                    }
                    .catch {
                        log(error: $0.localizedDescription)
                    }
            } else {
                self.createChecklist(checklist, shouldCreateTemplate: self.isCreateTemplateChecked)
            }
        }.catch { $0.log(message: "Failed to verify CreateChecklist restriction") }
        
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
            guard isReminderSet, let reminderDate = checklistToUpdate.reminderDate else {
                return .value
            }
            return self.notificationManager.setupReminder(date: reminderDate, for: checklistToUpdate)
        }.then {
            self.checklistDataSource.updateChecklist(checklistToUpdate)
        }.done {
            self.currentChecklist.send(checklistToUpdate)
            log(debug: "Update checklist success. \(checklistToUpdate)")
        }.catch { error in
            log(error: "Update checklist failed. \(error.localizedDescription)")
        }
    }
    
    func insertEmptyItemIfNeedd() {
        if items.isEmpty {
            addNewItem(name: nil, isDone: false, isEditable: true)
        } else if let lastItem = items.last, !lastItem.name.isEmpty {
            addNewItem(name: nil, isDone: false, isEditable: true)
        }
    }
    
    func clearEmptyItems() {
        let emptyItems = items.filter{ $0.name.isEmpty && $0 != items.last }
        if !emptyItems.isEmpty {
            emptyItems.forEach { emptyItem in
                items.removeAll { emptyItem == $0 }
            }
        }
        objectWillChange.send()
    }
    
    func addNewItem(name: String?, isDone: Bool, isEditable: Bool) {
        let id = UUID().uuidString
        let viewModel = ChecklistItemViewModel(id: id, name: name, isDone: isDone, isEditable: isEditable)
        viewModel.onTextDidClear.sink { [weak self]  in
            withAnimation {
                self?.clearEmptyItems()
            }
        }.store(in: &cancellables)
        viewModel.onNameChanged.sink { [weak self] _ in
            withAnimation {
                self?.insertEmptyItemIfNeedd()
            }
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
        checklistDescription = template.description ?? ""
        template.items.forEach { self.addNewItem(name: $0.name, isDone: false, isEditable: true) }
        addNewItem(name: nil, isDone: false, isEditable: true)
    }
    
    func getChecklistFromUI(id: String? = nil) -> ChecklistDataModel {
        let now = Date()
        return ChecklistDataModel(
            id: id ?? UUID().uuidString,
            title: self.checklistName,
            description: self.checklistDescription,
            creationDate: self.currentChecklist.value?.creationDate ?? now,
            updateDate: now,
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
            .get { _ in
                if shouldCreateTemplate {
                    self.createTemplate(checklist)
                } else {
                    self.shouldDismissView = true
                }
            }
            .catch {
                $0.log(message: "Failed to create checklist")
                #warning("TODO(): Implement proper error handling")
            }
    }
    
    func createTemplate(_ checklist: ChecklistDataModel) {
        firstly {
            restrictionManager.verifyCreateTemplate(presenter: self)
        }.then { verified -> Promise<Bool> in
            guard verified else {
                return .value(false)
            }
            self.shouldDismissView = true
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
            ).map { _ in verified}
        }.get { verified in
            if verified {
                self.didCreateTemplateSubject.send()
            } else {
                self.shouldDismissView = true
            }
        }.catch { error in
            error.log(message: "Failed to create template")
            #warning("TODO(): Implement proper error handling")
        }
    }
    
    func updateTemplate() {
        guard let template = viewState.template else {
            log(warning: "Template not available")
            return
        }
        let checklist = getChecklistFromUI()
        let templateToUpdate = TemplateDataModel(
            id: template.id,
            title: checklist.title,
            description: checklist.description,
            items: checklist.items
        )
        templateDataSource.updateTemplate(templateToUpdate).get {
            self.didUpdateTemplate.send()
        }.catch { error in
            error.log(message: "Failed to update template")
        }
    }
    
    #if canImport(UIKit)
    func resignFirstResponder() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    #endif
    
    func enableEditMode() {
        guard let checklist = self.currentChecklist.value else {
            return
        }
        self.isEditable = true
        self.items.forEach { $0.isEditable = true }
        self.isReminderOn = checklist.isValidReminderSet
        self.reminderDate = checklist.reminderDate ?? Date()
        self.viewState = .update(checklist: checklist)
    }
}


extension ChecklistViewModel: ChecklistActionSheetDelegate {
    
    func onEditAction(checklist: ChecklistDataModel) {
        withAnimation {
            navBarViewModel.shouldDisplayDoneButton = true
            onEditTapped.send()
        }
    }
    
    func onMarkAllDoneAction(checklist: ChecklistDataModel) {
        alert = .confirmMarkAllDone(onConfirm: { [weak self] in
            guard let self = self else { return }
            self.items.forEach { item in
                item.isDone = true
            }
            self.updateChecklist()
        })
    }
    
    func onMarkAllUndoneAction(checklist: ChecklistDataModel) {
        alert = .confirmMarkAllUnDone(onConfirm: { [weak self] in
            guard let self = self else { return }
            self.items.forEach { item in
                item.isDone = false
            }
            self.updateChecklist()
        })
    }
    
    func onSetReminderAction(checklist: ChecklistDataModel) {
        guard let checklist = currentChecklist.value else {
            return
        }
        let viewModel = AppContext.resolver.resolve(EditReminderViewModel.self, argument: checklist)!
        viewModel.onDidDeleteReminder.sink { [weak self] in
            self?.currentChecklist.value?.reminderDate = nil
            self?.sheetVisibility.isVisible = false
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        viewModel.onDidCreateReminder.sink { [weak self] date in
            self?.currentChecklist.value?.reminderDate = date
            self?.sheetVisibility.isVisible = false
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        let view = EditReminderView(viewModel: viewModel)
        sheetVisibility.set(view: AnyView(view), isVisible: true)
    }
    
    func onSaveAsTemplateAction(checklist: ChecklistDataModel) {
        guard let checklist = currentChecklist.value else {
            return
        }
        let viewModel = AppContext.resolver.resolve(
            ChecklistViewModel.self,
            argument: ChecklistViewState.createTemplate(checklist: checklist)
            )!
        viewModel.onDidCreateTemplate.sink { [weak self] in
            self?.alert = .templateCreated(onGoToTemplates: {
                guard let self = self else { return }
                let viewModel = AppContext.resolver.resolve(MyTemplatesViewModel.self)!
                self.navigationDestinationView = AnyView(MyTemplatesView(viewModel: viewModel))
                self.isNavigationLinkActive = true
                viewModel.onBackTapped.sink { [weak self] in
                    self?.isNavigationLinkActive = false
                }.store(in: &self.cancellables)
            })
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        let view = ChecklistView(viewModel: viewModel)
        sheetVisibility.set(view: AnyView(view), isVisible: true)
    }
    
    func onDeleteAction(checklist: ChecklistDataModel) {
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


extension ChecklistViewModel: RestrictionPresenter {
    
    func presentRestrictionAlert(_ alert: Alert) {
        alertVisibility.set(view: alert, isVisible: true)
        self.objectWillChange.send()
    }
    
    func presentUpgradeView(_ upgradeView: UpgradeView) {
        sheetVisibility.set(view: AnyView(upgradeView), isVisible: true)
        self.objectWillChange.send()
    }
    
    func cancelUpgradeView() {
        sheetVisibility.set(view: AnyView.empty, isVisible: false)
        self.objectWillChange.send()
    }
    
    func dismissUpgradeView() {
        sheetVisibility.set(view: AnyView.empty, isVisible: false)
        self.objectWillChange.send()
    }
}
