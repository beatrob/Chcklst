//
//  TemplateDataModel.swift
//  checklist
//
//  Created by Róbert Konczi on 30/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation


struct TemplateDataModel: Equatable {
    
    let id: String
    let title: String
    let description: String?
    var items: [ChecklistItemDataModel]
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    init(
        id: String,
        title: String,
        description: String?,
        items: [ChecklistItemDataModel]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.items = items
    }
    
    init(checklist: ChecklistDataModel) {
        id = UUID().uuidString
        title = checklist.title
        description = checklist.description
        items = checklist.items
    }
}
