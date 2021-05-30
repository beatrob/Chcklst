//
//  ScheduleMO.swift
//  checklist
//
//  Created by Robert Konczi on 5/30/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit


@objc(ScheduleMO)
public class ScheduleMO: NSManagedObject {

}

extension ScheduleMO {

    @NSManaged public var identifier: String
    @NSManaged public var notes: String?
    @NSManaged public var scheduleDate: Date
    @NSManaged public var title: String
    @NSManaged public var repeatFrequencies: NSSet?
    @NSManaged public var template: TemplateMO?
}
