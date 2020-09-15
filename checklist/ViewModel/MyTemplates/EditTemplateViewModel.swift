//
//  EditTemplateViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 30/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


class EditTemplateViewModel: ObservableObject {
    
    struct ItemVO {
        let id: String
        @Binding var name: String
    }
    
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var items: [ItemVO] = []
    @Published var shouldDismissView = false
    
    var itemIdToName: [String: String] = [:]
    var cancellables =  Set<AnyCancellable>()
    
    let onSave = EmptySubject()
    
    init(
        template: TemplateDataModel,
        updateTemplate: TemplatePassthroughSubject
    ) {
        self.title = template.title
        self.description = template.description ?? ""
        self.items = template.items.map { item in
            self.itemIdToName[item.id] = item.name
            return ItemVO(
                id: item.id,
                name: .init(
                    get: { self.itemIdToName[item.id] ?? "" },
                    set: { self.itemIdToName[item.id] = $0 }
                )
            )
        }
        
        onSave.sink { [weak self] in
            guard let self = self else { return }
            updateTemplate.send(
                TemplateDataModel(
                    id: template.id,
                    title: self.title,
                    description: self.description.nilWhenEmpty,
                    items: self.itemIdToName.keys.map {
                        ChecklistItemDataModel(
                            id: $0,
                            name: self.itemIdToName[$0]!,
                            isDone: false,
                            updateDate: Date())
                    }
                )
            )
            self.shouldDismissView = true
        }.store(in: &cancellables)
    }
}
