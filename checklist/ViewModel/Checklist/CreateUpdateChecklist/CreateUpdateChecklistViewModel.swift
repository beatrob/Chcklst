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

struct CreateChecklistItemVO {
    
    let id: String
    let viewModel: ChecklistItemViewModel
}

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
    var items: [CreateChecklistItemVO] = []
    
    let onCreateTitleNext: EmptySubject = .init()
    let onAddItemsNext: EmptySubject = .init()
    let onDeleteItem: PassthroughSubject<CreateChecklistItemVO, Never> = .init()
    
    let input: Input
    let notificationManager: NotificationManager
    
    var shouldDisplayNextAfterItems: Bool {
        !checklistName.isEmpty &&
            !idToName.values.filter { !$0.isEmpty }.isEmpty &&
            !shouldDisplayFinalizeView
    }
    var cancellables =  Set<AnyCancellable>()
    var idToName = [String: String]()
    
    init(
        input: Input,
        notificationManager: NotificationManager
    ) {
        self.input = input
        self.notificationManager = notificationManager
        
        if let template = input.template {
            setupTemplate(template)
        }
        
        onCreateTitleNext.sink { [weak self] in
            self?.addNewItem()
            self?.shouldCreateChecklistName = false
        }.store(in: &cancellables)
        
        onAddItemsNext.sink { [weak self] in
            self?.shouldDisplayFinalizeView = true
        }.store(in: &cancellables)
        
        onDeleteItem.sink { [weak self] item in
            self?.idToName[item.id] = nil
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
    
    func addNewItem(name: String? = nil, isDone: Bool = false) {
        let id = UUID().uuidString
        let item = CreateChecklistItemVO(
            id: id,
            viewModel: .init(name: name, isDone: isDone)
        )
        self.idToName[id] = name
        self.items.append(item)
        self.objectWillChange.send()
    }
    
    func setupTemplate(_ template: TemplateDataModel) {
        checklistName = template.title
        template.items.forEach { self.addNewItem(name: $0.name) }
        addNewItem()
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
                guard let name = self.idToName[$0.id] else {
                    return nil
                }
                return ChecklistItemDataModel(
                    id: UUID().uuidString,
                    name: name,
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
                    guard let name = self.idToName[$0.id] else {
                        return nil
                    }
                    return ChecklistItemDataModel(
                        id: UUID().uuidString,
                        name: name,
                        isDone: false,
                        updateDate: Date()
                    )
                }
            )
        )
    }
}
