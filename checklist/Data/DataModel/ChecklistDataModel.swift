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
    let description: String?
    var creationDate: Date
    var updateDate: Date
    var reminderDate: Date?
    var items: [ChecklistItemDataModel]
    var isDone: Bool {
        items.filter(\.isDone).count == items.count
    }
    var isArchived: Bool = false
    
    var isValidReminderSet: Bool {
        guard let reminderDate = reminderDate else {
            return false
        }
        return reminderDate >= Date()
    }
    
    mutating func removeReminderDate() {
        reminderDate = nil
    }
    
    mutating func updateToCurrentDate() {
        updateDate = Date()
    }
    
    func getWithCurrentUpdateDate() -> ChecklistDataModel {
        .init(
            id: id,
            title: title,
            description: description,
            creationDate: creationDate,
            updateDate: Date(),
            reminderDate: reminderDate,
            items: items,
            isArchived: isArchived
        )
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
