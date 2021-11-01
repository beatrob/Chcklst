//
//  TemplateDataModel.swift
//  checklist
//
//  Created by Róbert Konczi on 30/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation


struct TemplateDataModel: Equatable, Hashable {
    
    let id: String
    let title: String
    let description: String?
    let created: Date
    var items: [ItemDataModel]
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    init(
        id: String,
        title: String,
        description: String?,
        items: [ItemDataModel],
        created: Date
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.items = items
        self.created = created
    }
    
    init(checklist: ChecklistDataModel) {
        id = UUID().uuidString
        title = checklist.title
        description = checklist.description
        items = checklist.items
        created = Date()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}
