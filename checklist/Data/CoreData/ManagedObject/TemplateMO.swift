//
//  TemplateMO.swift
//  checklist
//
//  Created by Robert Konczi on 5/30/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit

@objc(TemplateMO)
public class TemplateMO: NSManagedObject { }


extension TemplateMO {
    
    static let entityName = "Template"
    
    @NSManaged public var identifier: String
    @NSManaged public var items: ChecklistItemArrayTransformable?
    @NSManaged public var notes: String?
    @NSManaged public var title: String
    @NSManaged public var schedules: NSSet?
}
