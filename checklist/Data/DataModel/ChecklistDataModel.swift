//
//  ChecklistDataModel.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation


struct ChecklistDataModel: Equatable, Hashable {
    
    let id: String
    let title: String
    let description: String?
    let creationDate: Date
    let updateDate: Date
    let reminderDate: Date?
    let items: [ItemDataModel]
    
    var isDone: Bool {
        items.filter(\.isDone).count == items.count && !items.isEmpty
    }
    
    var isValidReminderSet: Bool {
        guard let reminderDate = reminderDate else {
            return false
        }
        return reminderDate >= Date()
    }
    
    var hasExpiredReminder: Bool {
        guard let reminderDate = reminderDate else {
            return false
        }
        return reminderDate < Date()
    }
    
    func getWithCurrentUpdateDate() -> ChecklistDataModel {
        .init(
            id: id,
            title: title,
            description: description,
            creationDate: creationDate,
            updateDate: Date(),
            reminderDate: reminderDate,
            items: items
        )
    }
    
    func getWithAllItemsDone() -> ChecklistDataModel {
        .init(
            id: id,
            title: title,
            description: description,
            creationDate: creationDate,
            updateDate: Date(),
            reminderDate: reminderDate,
            items: items.map {
                ItemDataModel(
                    id: $0.id,
                    name: $0.name,
                    isDone: false,
                    updateDate: !$0.isDone ? $0.updateDate : Date()
                )
            }
        )
    }
    
    func getWithAllItemsUndone() -> ChecklistDataModel {
        .init(
            id: id,
            title: title,
            description: description,
            creationDate: creationDate,
            updateDate: Date(),
            reminderDate: reminderDate,
            items: items.map {
                ItemDataModel(
                    id: $0.id,
                    name: $0.name,
                    isDone: true,
                    updateDate: $0.isDone ? $0.updateDate : Date()
                )
            }
        )
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
