//
//  RepeatFrequencyMO.swift
//  checklist
//
//  Created by Robert Konczi on 5/30/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import CoreData


extension RepeatFrequencyMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RepeatFrequencyMO> {
        return NSFetchRequest<RepeatFrequencyMO>(entityName: "RepeatFrequency")
    }
}

// MARK: Generated accessors for schedules
extension RepeatFrequencyMO {

    @objc(addSchedulesObject:)
    @NSManaged public func addToSchedules(_ value: ScheduleMO)

    @objc(removeSchedulesObject:)
    @NSManaged public func removeFromSchedules(_ value: ScheduleMO)

    @objc(addSchedules:)
    @NSManaged public func addToSchedules(_ values: NSSet)

    @objc(removeSchedules:)
    @NSManaged public func removeFromSchedules(_ values: NSSet)

}

extension RepeatFrequencyMO : Identifiable {

}
