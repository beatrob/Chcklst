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
                    }
                }
                .catch { log(error: $0.localizedDescription) }
        }
    }
    @Published var reminderDate: Date = Date()
    @Published var isCreateTemplateChecked: Bool = false
    var shouldDisplaySetReminder: Bool { viewState.isCreateFromTemplate || viewState.isCreateNew }
    var shouldDisplaySaveAsTemplate: Bool { viewState.isCreateNew }
    var shouldDisplayActionButton: Bool { viewState.isEditEnabled }
    var isEditable: Bool { viewState.isEditEnabled }
    
    @Published var checklistName: String = ""
    @Published var checklistDescription: String?
    var items: [ChecklistItemViewModel] = []
    
    
    @Published var viewState: ChecklistViewState
    
    let onCreateTitleNext: EmptySubject = .init()
    let onAddItemsNext: EmptySubject = .init()
    let onDeleteItem: PassthroughSubject<ChecklistItemViewModel, Never> = .init()
    let onEditTapped: EmptySubject = .init()
    let onDoneTapped: EmptySubject = .init()
    let onActionButtonTapped: EmptySubject = .init()
    
    let input: Input
    let checklistDataSource: ChecklistDataSource
    let notificationManager: NotificationManager
    var cancellables =  Set<AnyCancellable>()
    
    init(
        input: Input,
        checklistDataSource: ChecklistDataSource,
        notificationManager: NotificationManager
    ) {
        self.input = input
        self.checklistDataSource = checklistDataSource
        self.notificationManager = notificationManager
        self.viewState = input.state
        
        if let template = input.template {
            setupTemplate(template)
        } else if input.state.isDisplay {
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
                let checklist = self.viewState.checklist
            else {
                return
            }
            self.viewState = .update(checklist: checklist)
        }.store(in: &cancellables)
        
        onDoneTapped.sink { [weak self] in
            guard
                let self = self,
                let checklist = self.viewState.checklist
            else {
                return
            }
            self.viewState = .display(checklist: checklist)
        }.store(in: &cancellables)
        
        onActionButtonTapped.sink { [weak self] in
            guard let self = self else { return }
            if self.input.state.isUpdate {
                
            } else {
                self.saveNewChecklist()
            }
        }.store(in: &cancellables)
    }
}


private extension ChecklistViewModel {
    
    func setupDisplayChecklist() {
        guard let checklist = input.checklist else {
            return
        }
        shouldCreateChecklistName = false
        self.checklistName = checklist.title
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
                let checklist = self.input.checklist
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
                    isDone: false,
                    updateDate: Date()
                )
            }
        )
    }
    
    func createChecklist(_ checklist: ChecklistDataModel, shouldCreateTemplate: Bool) {
        self.input.createChecklistSubject.send(checklist)
        guard shouldCreateTemplate else {
            return
        }
        self.input.createTemplateSubject.send(
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
}
