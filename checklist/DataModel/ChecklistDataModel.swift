//
//  ChecklistDataModel.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation


struct ChecklistDataModel {
    
    let id: String
    let title: String
    let description: String
    let items: [ChecklistItemDataModel]
    var isDone: Bool {
        items.filter(\.isDone).count == items.count
    }
}
