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
    var shouldDisplaySaveAsTemplate: Bool { viewState.isCreateChecklist }
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
    @Published var isSheetVisible: Bool = false
    @Published var sheet: AnyView = .empty
    @Published var actionSheetVisibility = ViewVisibility(view: ChecklistActionSheet.none.view)
    @Published var enableAutoscrollToNewItem = false
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
    
    /// Create Checklist or Template
    let createViewNavbarViewModel: BackButtonNavBarViewModel = BackButtonNavBarViewModel(title: "Create Checklist")
    let onAddItemsNext: EmptySubject = .init()
    let onDeleteItem: PassthroughSubject<ChecklistItemViewModel, Never> = .init()
    let onEditTapped: EmptySubject = .init()
    let onDoneTapped: EmptySubject = .init()
    let onActionButtonTapped: EmptySubject = .init()
    let dismissView = EmptySubject()
    let onBackTapped = EmptySubject()
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
        viewModel.backButton.didTap.subscribe(dismissView).store(in: &cancellables)
        viewModel.actionsButton.didTap.sink { [weak self] tupple in
            guard let self = self, let checklist = self.currentChecklist.value  else {
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
    var isNavBarVisible: Bool {
        guard !forceBigTitleNavbar else {
            return false
        }
        return !viewState.isCreateTemplate && currentChecklist.value != nil
    }
    private var currentChecklist: ChecklistCurrentValueSubject
    private var forceBigTitleNavbar = false
    
    
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
            createViewNavbarViewModel.style = .big
            createViewNavbarViewModel.isBackButtonHidden = true
            createViewNavbarViewModel.isTransparent = false
        } else if viewState.isDisplay || viewState.isUpdate {
            setupDisplayChecklist(isUpdate: viewState.isUpdate)
        }
        
        if viewState.isCreateChecklist {
            createViewNavbarViewModel.style = viewState.isCreateFromTemplate ? .normal : .big
            createViewNavbarViewModel.isBackButtonHidden = !viewState.isCreateFromTemplate
            createViewNavbarViewModel.topPaddingEnabled = viewState.isCreateFromTemplate
            createViewNavbarViewModel.isTransparent = viewState.isCreateFromTemplate
            createViewNavbarViewModel.backButton.didTap.subscribe(onBackTapped).store(in: &cancellables)
            addNewItemIfNeeded(name: nil, isDone: false, isEditable: true)
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
            case .updateChecklist:
                self.setEditDoneAndUpdateChecklist()
            case .createChecklistFromTemplate, .createChecklist:
                self.saveNewChecklist()
            case .createTemplateFromChecklist, .createTemplate:
                self.createTemplate(self.getChecklistFromUI())
            case .updateTemplate:
                self.updateTemplate()
            default:
                break
            }

        }.store(in: &cancellables)
    }
    
    func setBigTitleNavBar(isTransparent: Bool) {
        forceBigTitleNavbar = true
        createViewNavbarViewModel.style = .big
        createViewNavbarViewModel.isBackButtonHidden = true
        createViewNavbarViewModel.topPaddingEnabled = true
        createViewNavbarViewModel.isTransparent = isTransparent
    }
}


// MARK: - Private methods

private extension ChecklistViewModel {
    
    func setEditDoneAndUpdateChecklist() {
        guard let checklist = self.currentChecklist.value else {
            return
        }
        items.removeAll { $0.name.isEmpty }
        items.forEach {
            $0.isEditable = false
            $0.isCheckable = true
        }
        isEditable = false
        resignFirstResponder()
        updateChecklist()
        viewState = .display(checklist: checklist)
    }
    
    func setupDisplayChecklist(isUpdate: Bool) {
        guard let checklist = currentChecklist.value else {
            return
        }
        self.checklistName = checklist.title
        self.checklistDescription = checklist.description ?? ""
        checklist.items.forEach { self.addNewItem($0) }
        reorderItems()
        if isUpdate {
            enableEditMode()
        }
    }
    
    func setupCreateTemplate() {
        createViewNavbarViewModel.title = "Create Template"
        self.checklistName = currentChecklist.value?.title ?? ""
        self.checklistDescription = currentChecklist.value?.description ?? ""
        currentChecklist.value?.items
            .sorted { $0.updateDate < $1.updateDate }
            .forEach { addNewItemIfNeeded(name: $0.name, isDone: false, isEditable: true) }
        addNewItemIfNeeded(name: nil, isDone: false, isEditable: true)
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
        self.enableAutoscrollToNewItem = false
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
            self.navBarViewModel.shouldDisplayDoneButton = false
            self.currentChecklist.send(checklistToUpdate)
            self.reorderItems()
            log(debug: "Update checklist success. \(checklistToUpdate)")
        }.catch { error in
            log(error: "Update checklist failed. \(error.localizedDescription)")
        }
    }
    
    func insertEmptyItemIfNeedd() {
        if items.isEmpty {
            addNewItemIfNeeded(name: nil, isDone: false, isEditable: true)
        } else if let lastItem = items.last, !lastItem.name.isEmpty {
            self.enableAutoscrollToNewItem = true
            addNewItemIfNeeded(name: nil, isDone: false, isEditable: true)
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
    
    func addNewItemIfNeeded(name: String?, isDone: Bool, isEditable: Bool) {
        guard !(items.last?.name.isEmpty ?? false) else {
            return
        }
        let viewModel = ChecklistItemViewModel(
            item: .init(id: UUID().uuidString, name: name ?? "", isDone: isDone, updateDate: .now),
            isEditable: isEditable,
            isCheckable: !isEditable,
            itemDataSource: AppContext.resolver.resolve(ItemDataSource.self)!
        )
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
        viewModel.onDidChangeDoneState.sink { [weak self] _ in
            self?.reloadCurrentChecklist()
        }.store(in: &cancellables)
        self.items.append(viewModel)
        self.objectWillChange.send()
    }
    
    func addNewItem(_ item: ItemDataModel) {
        let viewModel = ChecklistItemViewModel(
            item: item,
            isEditable: false,
            isCheckable: true,
            itemDataSource: AppContext.resolver.resolve(ItemDataSource.self)!
        )
        
        viewModel.onDidChangeDoneState.sink { [weak self] isDone in
            self?.reloadCurrentChecklist()
        }.store(in: &cancellables)
        
        self.items.append(viewModel)
        self.objectWillChange.send()
    }
    
    func reloadCurrentChecklist() {
        guard let checklist = self.currentChecklist.value else {
            return
        }
        self.checklistDataSource.reloadChecklist(checklist).get {
            self.currentChecklist.value = $0
            self.reorderItems()
        }.catch { error in
            error.log(message: "Failed to update current Checklist")
        }
    }
    
    func setupTemplate(_ template: TemplateDataModel) {
        if viewState.isEditTemplate {
            createViewNavbarViewModel.title = "Edit Template"
        }
        checklistName = template.title
        checklistDescription = template.description ?? ""
        template.items.forEach { self.addNewItemIfNeeded(name: $0.name, isDone: false, isEditable: true) }
        addNewItemIfNeeded(name: nil, isDone: false, isEditable: true)
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
                return ItemDataModel(
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
                    self.dismissView.send()
                }
            }
            .catch {
                $0.log(message: "Failed to create checklist")
            }
    }
    
    func createTemplate(_ checklist: ChecklistDataModel) {
        firstly {
            restrictionManager.verifyCreateTemplate(
                presenter: self,
                isCreateFromScratch: viewState.isCreateTemplate
            )
        }.then { verified -> Promise<Bool> in
            guard verified else {
                return .value(false)
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
                        return ItemDataModel(
                            id: UUID().uuidString,
                            name: $0.name,
                            isDone: false,
                            updateDate: Date()
                        )
                    },
                    created: Date()
                )
            ).map { _ in verified}
        }.get { verified in
            if verified {
                self.didCreateTemplateSubject.send()
                self.dismissView.send()
            } else if self.viewState.isCreateChecklist {
                self.dismissView.send()
            }
        }.catch { error in
            error.log(message: "Failed to create template")
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
            items: checklist.items,
            created: template.created
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
        enableAutoscrollToNewItem = false
        isEditable = true
        items.forEach { $0.isEditable = true }
        isReminderOn = checklist.isValidReminderSet
        reminderDate = checklist.reminderDate ?? Date()
        viewState = .updateChecklist(checklist: checklist)
        navBarViewModel.shouldDisplayDoneButton = true
        addNewItemIfNeeded(name: nil, isDone: false, isEditable: true)
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
        
        viewModel.onDidCreateReminder
            .map { _ in () }
            .merge(with: viewModel.onDidDeleteReminder)
            .sink { [weak self] in
                self?.sheet = .empty
                self?.isSheetVisible = false
                self?.checklistDataSource.reloadChecklist(checklist).get {
                    self?.currentChecklist.value = $0
                }.catch({ error in
                    error.log(message: "Failed to reload checklist")
                })
        }.store(in: &cancellables)
        
        let view = EditReminderView(viewModel: viewModel)
        sheet = AnyView(view)
        isSheetVisible = true
    }
    
    func onSaveAsTemplateAction(checklist: ChecklistDataModel) {
        guard let checklist = currentChecklist.value else {
            return
        }
        let viewModel = AppContext.resolver.resolve(
            ChecklistViewModel.self,
            argument: ChecklistViewState.createTemplateFromChecklist(checklist: checklist)
            )!
        viewModel.onDidCreateTemplate.sink { [weak self] in
            self?.isSheetVisible = false
            self?.sheet = .empty
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
            }
        }.store(in: &cancellables)
        let view = ChecklistView(viewModel: viewModel)
        sheet = AnyView(view)
        isSheetVisible = true
    }
    
    func onDeleteAction(checklist: ChecklistDataModel) {
        alert = .confirmDelete(onDelete: { [weak self] in
            guard let checklist = self?.currentChecklist.value else {
                return
            }
            self?.checklistDataSource.deleteChecklist(checklist)
                .done { self?.dismissView.send() }
                .catch { error in
                    error.log(message: "Failed to delete checklist")
                }
        })
    }
    
    func reorderItems() {
        guard !items.isEmpty else {
            return
        }
        withAnimation {
            let doneItems = items.filter { $0.isDone }.sorted { $0.updateDate < $1.updateDate }
            let undoneItems = items.filter { !$0.isDone }.sorted { $0.updateDate < $1.updateDate }
            items = undoneItems + doneItems
            objectWillChange.send()
        }
    }
}


extension ChecklistViewModel: RestrictionPresenter {
    
    func presentRestrictionAlert(_ alert: Alert) {
        alertVisibility.set(view: alert, isVisible: true)
        self.objectWillChange.send()
    }
    
    func presentUpgradeView(_ upgradeView: UpgradeView) {
        sheet = AnyView(upgradeView)
        isSheetVisible = true
    }
    
    func cancelUpgradeView() {
        self.sheet = AnyView.empty
        self.isSheetVisible = true
    }
    
    func dismissUpgradeView() {
        self.sheet = AnyView.empty
        self.isSheetVisible = false
    }
}
