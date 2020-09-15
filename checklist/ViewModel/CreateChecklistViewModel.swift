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

class CreateChecklistViewModel: ObservableObject {
    
    enum Constants {
        static let fromTemplate = "fromTemplate"
    }
    
    @Published var shouldCreateChecklistName: Bool = true {
        didSet {
            shouldDisplayAddItems = !shouldCreateChecklistName
        }
    }
    @Published var shouldDisplayAddItems: Bool = false
    @Published var checklistName: String = ""
    @Published var checklistDescription: String?
    @Published var shouldDismissView: Bool = false
    var items: [CreateChecklistItemVO] = []
    let onCreateTitleNext: EmptySubject = .init()
    let onCreateChecklist: EmptySubject = .init()
    
    var shouldDisplayCreateChecklist: Bool {
        !checklistName.isEmpty &&
            !idToName.values.filter { !$0.isEmpty }.isEmpty
    }
    var cancellables =  Set<AnyCancellable>()
    var idToName = [String: String]()
    
    init(
        createChecklistSubject: ChecklistPassthroughSubject,
        template: TemplateDataModel? = nil
    ) {
        if let template = template {
            setupTemplate(template)
        }
        onCreateTitleNext.sink { [weak self] in
            self?.addNewItem()
            self?.shouldCreateChecklistName = false
        }.store(in: &cancellables)
        
        onCreateChecklist.sink { [weak self] in
            guard let self = self else { return }
            createChecklistSubject.send(
                ChecklistDataModel(
                    id: UUID().uuidString,
                    title: self.checklistName,
                    description: self.checklistDescription,
                    updateDate: Date(),
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
            self.shouldDismissView = true
        }.store(in: &cancellables)
    }
    
    private func addNewItem(name: String? = nil) {
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
    
    private func setupTemplate(_ template: TemplateDataModel) {
        checklistName = template.title
        template.items.forEach { self.addNewItem(name: $0.name) }
        addNewItem()
        shouldCreateChecklistName = false
    }
}
