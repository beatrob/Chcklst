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


extension ScheduleMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScheduleMO> {
        return NSFetchRequest<ScheduleMO>(entityName: "Schedule")
    }
    
    @nonobjc public class func fetchRequest(withId id: String) -> NSFetchRequest<ScheduleMO> {
        let request = NSFetchRequest<ScheduleMO>(entityName: "Schedule")
        request.predicate = NSPredicate(format: "identifier == %@", id)
        request.fetchLimit = 1
        return request
    }
    
    func toDataModel() -> ScheduleDataModel? {
        guard let template = self.template else {
            return nil
        }
        return .init(
            id: identifier,
            title: title,
            description: notes,
            template: template.toTemplateDataModel(),
            scheduleDate: scheduleDate,
            repeatFrequency: getRepeatFrequncy()
        )
    }
    
    func setup(with dataModel: ScheduleDataModel) {
        identifier = dataModel.id
        title = dataModel.title
        notes = dataModel.description
        scheduleDate = dataModel.scheduleDate
        repeatFrequencies = NSSet(array: dataModel.repeatFrequency.intValues.map { Int32($0) })
        template = TemplateMO()
        template?.setup(with: dataModel.template)
    }
    
    static func createEntity(
        from dataModel: ScheduleDataModel,
        andSaveToContext context: NSManagedObjectContext
    ) -> Promise<Void> {
        guard let entity = NSEntityDescription.entity(forEntityName: "Schedule", in: context) else {
            return .init(error: CoreDataError.createEntityError)
        }
        let scheduleMO = ScheduleMO(entity: entity, insertInto: context)
        scheduleMO.setup(with: dataModel)
        return .value
    }
    
    private func getRepeatFrequncy() -> ScheduleDataModel.RepeatFrequency {
        guard let repeatFreqs = repeatFrequencies, repeatFreqs.count > 0 else {
            return .never
        }
        let freqRaws = repeatFreqs.compactMap { freq -> Int? in
            guard let freqMO = freq as? RepeatFrequencyMO else {
                return nil
            }
            return Int(freqMO.identifier)
        }
        guard !freqRaws.isEmpty else {
            return .never
        }
        
        let customDays = freqRaws.compactMap { DayDataModel(rawValue: $0) }
        if !customDays.isEmpty {
            return .customDays(days: customDays)
        } else {
            return freqRaws
                .compactMap { ScheduleDataModel.RepeatFrequency(rawValue: $0) }
                .first ?? .never
        }
    }
}

// MARK: Generated accessors for repeatFrequencies
extension ScheduleMO {

    @objc(addRepeatFrequenciesObject:)
    @NSManaged public func addToRepeatFrequencies(_ value: RepeatFrequencyMO)

    @objc(removeRepeatFrequenciesObject:)
    @NSManaged public func removeFromRepeatFrequencies(_ value: RepeatFrequencyMO)

    @objc(addRepeatFrequencies:)
    @NSManaged public func addToRepeatFrequencies(_ values: NSSet)

    @objc(removeRepeatFrequencies:)
    @NSManaged public func removeFromRepeatFrequencies(_ values: NSSet)

}
