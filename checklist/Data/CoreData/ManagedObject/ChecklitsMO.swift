//
//  ChecklitsMO.swift
//  checklist
//
//  Created by Robert Konczi on 5/30/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit


@objc(ChecklistMO)
public class ChecklistMO: NSManagedObject { }


extension ChecklistMO {

    @NSManaged public var creationDate: Date
    @NSManaged public var identifier: String
    @NSManaged public var notes: String?
    @NSManaged public var reminderDate: Date?
    @NSManaged public var title: String
    @NSManaged public var updateDate: Date
    @NSManaged public var items: NSSet?
}
