//
//  ChecklistDataModel.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation


struct ChecklistDataModel: Equatable {
    
    let id: String
    let title: String
    let description: String
    var updateDate: Date
    var items: [ChecklistItemDataModel]
    var isDone: Bool {
        items.filter(\.isDone).count == items.count
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
