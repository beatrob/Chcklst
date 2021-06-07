//
//  CoreDataManager+Schedules.swift
//  checklist
//
//  Created by Robert Konczi on 5/30/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import PromiseKit
import CoreData


extension CoreDataManagerImpl: CoreDataSchedulesManager {
    
    func fetchAllSchedules() -> Promise<[ScheduleDataModel]> {
        firstly {
            getViewContext()
        }.then { context -> Promise<[ScheduleMO]> in
            guard let data = try context.fetch(ScheduleMO.fetchRequest()) as? [ScheduleMO] else {
                throw CoreDataError.fetchError
            }
            return .value(data)
        }.map {
            schedules in schedules.compactMap { $0.toDataModel() }
        }
    }
    
    func fetchSchedule(with id: String) -> Promise<ScheduleDataModel> {
        firstly {
            getViewContext()
        }.then { context -> Promise<ScheduleMO> in
            guard
                let data = try context.fetch(ScheduleMO.fetchRequest(withId: id)).first
            else {
                throw CoreDataError.fetchError
            }
            return .value(data)
        }.map {
            guard let dataModel = $0.toDataModel() else {
                throw CoreDataError.fetchError
            }
            return dataModel
        }
    }
    
    func save(schedule: ScheduleDataModel) -> Promise<Void> {
        firstly { getViewContext() }
        .then { context -> Promise<Void> in
            ScheduleMO.createEntity(from: schedule, andSaveToContext: context).asVoid()
        }
        .then { self.saveContext() }
    }
    
    func update(schedule: ScheduleDataModel) -> Promise<Void> {
        firstly {
            getViewContext()
        }.then { context -> Promise<(NSManagedObjectContext, [RepeatFrequencyMO])> in
            RepeatFrequencyMO.getRepeatFrequencyMOs(
                for: schedule.repeatFrequency,
                context: context
            ).map { (context, $0) }
        }.then { contextAndRepeatFreqMOs -> Promise<Void> in
            guard
                let scheduleMO = try contextAndRepeatFreqMOs.0.fetch(ScheduleMO.fetchRequest(withId: schedule.id)).first
            else {
                throw CoreDataError.fetchError
            }
            scheduleMO.setup(with: schedule, freqMOs: contextAndRepeatFreqMOs.1, templateMO: nil)
            return .value
        }.then {
            self.saveContext()
        }
    }
    
    func delete(schedule: ScheduleDataModel) -> Promise<Void> {
        firstly { getViewContext() }
        .then { context -> Promise<Void> in
            guard let scheduleMO = try context.fetch(ScheduleMO.fetchRequest(withId: schedule.id)).first else {
                throw CoreDataError.fetchError
            }
            context.delete(scheduleMO)
            return .value
        }
        .then { self.saveContext() }
    }
}
