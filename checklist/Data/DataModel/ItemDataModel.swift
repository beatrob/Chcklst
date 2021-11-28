//
//  ChecklistItemDataModel.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation


struct ItemDataModel: Equatable {
    
    let id: String
    var name: String
    var isDone: Bool
    var updateDate: Date
    
    static var empty: ItemDataModel {
        .init(id: UUID().uuidString, name: "", isDone: false, updateDate: .now)
    }
    
    var isUndone: Bool { !isDone }
    
    mutating func toDone() {
        self.isDone = true
        self.updateDate = Date()
    }
    
    mutating func toUnDone() {
        self.isDone = false
        self.updateDate = Date()
    }
    
    mutating func toggleDone() {
        self.isDone.toggle()
        self.updateDate = Date()
    }
    
    mutating func update(with item: ItemDataModel) {
        self.name = item.name
        self.isDone = item.isDone
        self.updateDate = item.updateDate
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    func getUnDoneCopy() -> Self {
        .init(id: id, name: name, isDone: false, updateDate: updateDate)
    }
}
