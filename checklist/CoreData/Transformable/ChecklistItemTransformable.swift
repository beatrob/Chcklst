//
//  ChecklistItemTransformable.swift
//  checklist
//
//  Created by Róbert Konczi on 28/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation


public class ChecklistItemArrayTransformable: NSObject, NSCoding {
    
    let checklistItems: [ChecklistItemTransformable]
    
    public func encode(with coder: NSCoder) {
        coder.encode(checklistItems, forKey: "checklistItems")
    }
    
    public required init?(coder: NSCoder) {
        checklistItems = coder.decodeObject(forKey: "checklistItems") as! [ChecklistItemTransformable]
    }
    
    init(checklistItems: [ChecklistItemDataModel]) {
        let items = checklistItems.map {
            ChecklistItemTransformable(
                id: $0.id,
                name: $0.name,
                isDone: $0.isDone,
                updateDate: $0.updateDate
            )
        }
        self.checklistItems = items
        super.init()
    }
}


public class ChecklistItemTransformable: NSObject, NSCoding {
    
    let id: String
    var name: String
    var isDone: Bool
    var updateDate: Date
    
    public func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "identifier")
        coder.encode(name, forKey: "name")
        coder.encode(isDone, forKey: "isDone")
        coder.encode(updateDate, forKey: "updateDate")
    }
    
    public required init?(coder: NSCoder) {
        id = coder.decodeObject(forKey: "identifier") as! String
        name = coder.decodeObject(forKey: "name") as! String
        isDone = coder.decodeBool(forKey: "isDone")
        updateDate = coder.decodeObject(forKey: "updateDate") as! Date
    }
    
    init(
        id: String,
        name: String,
        isDone: Bool,
        updateDate: Date
    ) {
        self.id = id
        self.name = name
        self.isDone = isDone
        self.updateDate = updateDate
    }
}
