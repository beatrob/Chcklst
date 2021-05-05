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
    func createSchedule(_ schedule: ScheduleDataModel) -> Promise<Void>
    func updateSchedule(_ schedule: ScheduleDataModel) -> Promise<Void>
    func deleteSchedule(_ schedule: ScheduleDataModel) -> Promise<Void>
}


class ScheduleDataSourceImpl: ScheduleDataSource {
    
    private let _schedules = CurrentValueSubject<[ScheduleDataModel], Never>([])
    var schedules: AnyPublisher<[ScheduleDataModel], Never> {
        _schedules.eraseToAnyPublisher()
    }
    
    func loadAllSchedules() -> Promise<[ScheduleDataModel]> {
        .value([])
    }
    
    func createSchedule(_ schedule: ScheduleDataModel) -> Promise<Void> {
        .value
    }
    
    func updateSchedule(_ schedule: ScheduleDataModel) -> Promise<Void> {
        .value
    }
    
    func deleteSchedule(_ schedule: ScheduleDataModel) -> Promise<Void> {
        .value
    }
}
