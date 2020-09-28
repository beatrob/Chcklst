//
//  Checklist+CoreDataProperties.swift
//  checklist
//
//  Created by Róbert Konczi on 27/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//
//

import Foundation
import CoreData


extension ChecklistMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChecklistMO> {
        return NSFetchRequest<ChecklistMO>(entityName: "Checklist")
    }

    @NSManaged public var identifier: String
    @NSManaged public var title: String
    @NSManaged public var notes: String?
    @NSManaged public var updateDate: Date
    @NSManaged public var items: NSObject?
    
    func toChecklistDataModel() -> ChecklistDataModel {
        .init(
            id: identifier,
            title: title,
            description: notes,
            updateDate: updateDate,
            items: []
        )
    }
}
