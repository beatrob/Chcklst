//
//  ScheduleDataSource.swift
//  checklist
//
//  Created by Robert Konczi on 5/5/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import PromiseKit
import Combine


protocol ScheduleDataSource {
    var schedules: AnyPublisher<[ScheduleDataModel], Never> { get }
    func loadAllSchedules() -> Promise<[ScheduleDataModel]>
    func createSchedule(_ schedule: ScheduleDataModel) -> Promise<ScheduleDataModel>
    func updateSchedule(_ schedule: ScheduleDataModel) -> Promise<Void>
    func deleteSchedule(_ schedule: ScheduleDataModel) -> Promise<Void>
    func getSchedule(with identifier: String) -> Promise<ScheduleDataModel>
}


class ScheduleDataSourceImpl: ScheduleDataSource {
    
    private let coreDataManager: CoreDataSchedulesManager
    private let _schedules = CurrentValueSubject<[ScheduleDataModel], Never>([])
    var schedules: AnyPublisher<[ScheduleDataModel], Never> {
        _schedules.eraseToAnyPublisher()
    }
    
    init(coreDataManager: CoreDataSchedulesManager) {
        self.coreDataManager = coreDataManager
    }
    
    func loadAllSchedules() -> Promise<[ScheduleDataModel]> {
        coreDataManager.fetchAllSchedules()
            .get { self._schedules.value = $0 }
    }
    
    func createSchedule(_ schedule: ScheduleDataModel) -> Promise<ScheduleDataModel> {
        coreDataManager.save(schedule: schedule)
            .get { self._schedules.value.append(schedule) }
            .map { schedule }
    }
    
    func updateSchedule(_ schedule: ScheduleDataModel) -> Promise<Void> {
        coreDataManager.update(schedule: schedule)
            .get {
                if let i = self._schedules.value.firstIndex(of: schedule) {
                    self._schedules.value.replaceSubrange(i...i, with: [schedule])
                }
            }
    }
    
    func deleteSchedule(_ schedule: ScheduleDataModel) -> Promise<Void> {
        coreDataManager.delete(schedule: schedule)
            .get { self._schedules.value.removeAll { $0 == schedule } }
    }
    
    func getSchedule(with identifier: String) -> Promise<ScheduleDataModel> {
        coreDataManager.fetchSchedule(with: identifier)
    }
}
