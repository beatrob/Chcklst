//
//  CoreDataManager+Schedules.swift
//  checklist
//
//  Created by Robert Konczi on 5/30/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import PromiseKit


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
    
    func save(schedule: ScheduleDataModel) -> Promise<Void> {
        firstly { getViewContext() }
        .then { context -> Promise<Void> in
            ScheduleMO.createEntity(from: schedule, andSaveToContext: context)
        }
        .then { self.saveContext() }
    }
    
    func update(schedule: ScheduleDataModel) -> Promise<Void> {
        firstly { getViewContext() }
        .then { context -> Promise<Void> in
            guard let scheduleMO = try context.fetch(ScheduleMO.fetchRequest(withId: schedule.id)).first else {
                throw CoreDataError.fetchError
            }
            scheduleMO.setup(with: schedule)
            return .value
        }
        .then { self.saveContext() }
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
