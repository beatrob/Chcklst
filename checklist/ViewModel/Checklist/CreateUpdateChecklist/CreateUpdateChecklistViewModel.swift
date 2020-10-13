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
    @Binding var name: String
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
    
    let createChecklistSubject: ChecklistPassthroughSubject
    let createTemplateSubject: TemplatePassthroughSubject
    let notificationManager: NotificationManager
    let input: Input
    
    var shouldDisplayNextAfterItems: Bool {
        !checklistName.isEmpty &&
            !idToName.values.filter { !$0.isEmpty }.isEmpty &&
            !shouldDisplayFinalizeView
    }
    var cancellables =  Set<AnyCancellable>()
    var idToName = [String: String]()
    
    init(
        createChecklistSubject: ChecklistPassthroughSubject,
        createTemplateSubject: TemplatePassthroughSubject,
        notificationManager: NotificationManager,
        input: Input
    ) {
        self.notificationManager = notificationManager
        self.createChecklistSubject = createChecklistSubject
        self.createTemplateSubject = createTemplateSubject
        self.input = input
        
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
        
        viewModel.onCreate.sink { [weak self] in
            guard let self = self else { return }
            let checklist = self.getChecklistFromUI(reminderDate: viewModel.isReminderOn ? viewModel.reminderDate : nil)
            if viewModel.isReminderOn {
                self.notificationManager.setupReminder(for: checklist)
                    .done {
                        self.createChecklist(checklist, shouldCreateTemplate: viewModel.isCreateTemplateChecked)
                        self.shouldDismissView = true
                    }
                    .catch {
                        #warning("TODO: Add proper error handling")
                        log(error: $0.localizedDescription)
                    }
            } else {
                self.createChecklist(checklist, shouldCreateTemplate: viewModel.isCreateTemplateChecked)
                self.shouldDismissView = true
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
    
    func addNewItem(name: String? = nil) {
        let id = UUID().uuidString
        let item = CreateChecklistItemVO(
            id: id,
            name: .init(
                get: { self.idToName[id] ?? "" },
                set: { [weak self] in
                    guard let self = self else { return }
                    self.idToName[id] = $0
                    if self.items.last?.id == id && !$0.isEmpty {
                        self.addNewItem()
                    }
                    self.objectWillChange.send()
                }
            )
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
    
    func getChecklistFromUI(reminderDate: Date?) -> ChecklistDataModel {
        ChecklistDataModel(
            id: UUID().uuidString,
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
        self.createChecklistSubject.send(checklist)
        guard shouldCreateTemplate else {
            return
        }
        self.createTemplateSubject.send(
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
