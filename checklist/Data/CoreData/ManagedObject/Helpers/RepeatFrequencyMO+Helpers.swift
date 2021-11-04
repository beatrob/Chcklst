//
//  RepeatFrequencyMO.swift
//  checklist
//
//  Created by Robert Konczi on 5/30/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit


extension RepeatFrequencyMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RepeatFrequencyMO> {
        return NSFetchRequest<RepeatFrequencyMO>(entityName: "RepeatFrequency")
    }
    
    @nonobjc public class func fetchRequest(withIds ids: [Int]) -> NSFetchRequest<RepeatFrequencyMO> {
        let request = NSFetchRequest<RepeatFrequencyMO>(entityName: "RepeatFrequency")
        request.predicate = NSCompoundPredicate(
            type: .or,
            subpredicates: ids.map { NSPredicate(format: "identifier == %d", $0) }
        )
        return request
    }
    
    static func getRepeatFrequencyMOs(
        for freqs: ScheduleDataModel.RepeatFrequency,
        context: NSManagedObjectContext
    ) -> Promise<[RepeatFrequencyMO]> {
        Promise{ resolver in
            let intValues = freqs.intValues
            let data = try context.fetch(RepeatFrequencyMO.fetchRequest(withIds: intValues))
            if data.count == freqs.intValues.count {
                resolver.fulfill(data)
            } else {
                let identifiers = data.map { Int($0.identifier) }
                let missingFreqs = intValues.filter { !identifiers.contains($0) }
                let newFreqs = try missingFreqs.map {
                    try RepeatFrequencyMO.createEntity(from: $0, andSaveToContext: context)
                }
                resolver.fulfill(data + newFreqs)
            }
        }
    }
    
    private static func createEntity(
        from repeatFrequencyValue: Int,
        andSaveToContext context: NSManagedObjectContext
    ) throws -> RepeatFrequencyMO {
        guard let entity = NSEntityDescription.entity(forEntityName: "RepeatFrequency", in: context) else {
            throw CoreDataError.createEntityError
        }
        let repeatFreqMO = RepeatFrequencyMO(entity: entity, insertInto: context)
        repeatFreqMO.identifier = Int32(repeatFrequencyValue)
        return repeatFreqMO
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
