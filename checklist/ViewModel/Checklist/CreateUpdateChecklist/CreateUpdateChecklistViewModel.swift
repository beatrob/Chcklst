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


class CreateUpdateChecklistViewModel: ObservableObject {
    
    @Published var shouldCreateChecklistName: Bool = true {
        didSet {
            shouldDisplayAddItems = !shouldCreateChecklistName
        }
    }
    @Published var shouldDisplayAddItems: Bool = false
    @Published var checklistName: String = ""
    @Published var checklistDescription: String?
    @Published var shouldDismissView: Bool = false
    @Published var shouldDisplayFinalizeView: Bool = false
    @Published var isEditable: Bool
    var items: [ChecklistItemViewModel] = []
    
    let onCreateTitleNext: EmptySubject = .init()
    let onAddItemsNext: EmptySubject = .init()
    let onDeleteItem: PassthroughSubject<ChecklistItemViewModel, Never> = .init()
    
    let input: Input
    let notificationManager: NotificationManager
    var cancellables =  Set<AnyCancellable>()
    
    init(
        input: Input,
        notificationManager: NotificationManager
    ) {
        self.input = input
        self.notificationManager = notificationManager
        self.isEditable = input.isEditable
        
        if let template = input.template {
            setupTemplate(template)
        } else if input.isDisplay {
            setupDisplayChecklist()
        }
        
        onCreateTitleNext.sink { [weak self] in
            self?.setupItemsAndFinalizeView()
            self?.shouldCreateChecklistName = false
        }.store(in: &cancellables)
        
        onAddItemsNext.sink { [weak self] in
            self?.shouldDisplayFinalizeView = true
        }.store(in: &cancellables)
        
        onDeleteItem.sink { [weak self] item in
            self?.items.removeAll { $0.id == item.id }
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    func getFinalizeCheckistViewModel() -> FinalizeChecklistViewModel {
        let viewModel = AppContext.resolver.resolve(FinalizeChecklistViewModel.self)!
        
        viewModel.onActionButton.sink { [weak self] in
            guard let self = self else { return }
            if self.input.isUpdate {
                
            } else {
                self.createChecklist(viewModel: viewModel)
            }
        }.store(in: &cancellables)
        
        viewModel.onReminderOnOff.sink { [weak self] isOn in
            guard let self = self else { return }
            guard isOn else {
                return
            }
            self.notificationManager.registerPushNotifications()
                .done { granted  in
                    if !granted {
                        viewModel.isReminderOn = false
                    }
                }
                .catch { log(error: $0.localizedDescription) }
        }.store(in: &cancellables)
        
        return viewModel
    }
}


private extension CreateUpdateChecklistViewModel {
    
    func setupDisplayChecklist() {
        guard let checklistSubject = input.checklistSubject else {
            return
        }
        shouldCreateChecklistName = false
        checklistSubject.sink { [weak self] checklist in
            guard
                let self = self,
                let checklist = checklist
            else {
                return
            }
            self.checklistName = checklist.title
            checklist.items.forEach { item in
                self.addNewItem(name: item.name, isDone: item.isDone, isEditable: false)
            }
        }.store(in: &cancellables)
    }
    
    func createChecklist(viewModel: FinalizeChecklistViewModel) {
        let checklist = self.getChecklistFromUI(reminderDate: viewModel.isReminderOn ? viewModel.reminderDate : nil)
        if viewModel.isReminderOn {
            self.notificationManager.setupReminder(for: checklist)
                .done {
                    self.createChecklist(checklist, shouldCreateTemplate: viewModel.isCreateTemplateChecked)
                    self.shouldDismissView = true
                }
                .catch {
                    log(error: $0.localizedDescription)
                }
        } else {
            self.createChecklist(checklist, shouldCreateTemplate: viewModel.isCreateTemplateChecked)
            self.shouldDismissView = true
        }
    }
    
    func updateChecklist(viewModel: FinalizeChecklistViewModel) {
        guard let checklist = input.checklistToUpdate else {
            log(error: "Trying to update, but checklist not found")
            return
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
        shouldDisplayFinalizeView = !items.filter({ !$0.name.isEmpty }).isEmpty && isEditable
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
    
    func setupTemplate(_ template: TemplateDataModel) {
        checklistName = template.title
        template.items.forEach { self.addNewItem(name: $0.name, isDone: false, isEditable: true) }
        addNewItem(name: nil, isDone: false, isEditable: true)
        shouldCreateChecklistName = false
    }
    
    func getChecklistFromUI(reminderDate: Date?, id: String? = nil) -> ChecklistDataModel {
        ChecklistDataModel(
            id: id ?? UUID().uuidString,
            title: self.checklistName,
            description: self.checklistDescription,
            updateDate: Date(),
            reminderDate: reminderDate,
            items: self.items.compactMap {
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
