//
//  MockScheduleDataSource.swift
//  checklist
//
//  Created by Robert Konczi on 5/5/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import PromiseKit


class MockScheduleDataSource: ScheduleDataSource {
    
    private let _schedules = CurrentValueSubject<[ScheduleDataModel], Never>([])
    var schedules: AnyPublisher<[ScheduleDataModel], Never> {
        _schedules.eraseToAnyPublisher()
    }
    
    func loadAllSchedules() -> Promise<[ScheduleDataModel]> {
        let schedules: [ScheduleDataModel] = [
            ScheduleDataModel(
                id: "1",
                title: "My first schedule",
                template: .init(checklist: .getWelcomeChecklist()),
                scheduleDate: Date().addingTimeInterval(60 * 60 * 24),
                repeatFrequency: .weekly
            ),
            ScheduleDataModel(
                id: "2",
                title: "My second schedule",
                template: .init(checklist: .getWelcomeChecklist()),
                scheduleDate: Date().addingTimeInterval(60 * 60 * 24 * 3),
                repeatFrequency: .daily
            ),
            ScheduleDataModel(
                id: "3",
                title: "My third schedule",
                template: .init(checklist: .getWelcomeChecklist()),
                scheduleDate: Date().addingTimeInterval(60 * 60 * 24 * 4),
                repeatFrequency: .customDays(days: [.monday, .thursday, .saturday])
            ),
        ]
        _schedules.value = schedules
        return .value(schedules)
    }
    
    func createSchedule(_ schedule: ScheduleDataModel) -> Promise<Void> {
        _schedules.value.append(schedule)
        return .value
    }
    
    func updateSchedule(_ schedule: ScheduleDataModel) -> Promise<Void> {
        if let i = _schedules.value.firstIndex(of: schedule) {
            _schedules.value.replaceSubrange(.init(uncheckedBounds: (i, i)), with: [schedule])
        }
        return .value
    }
    
    func deleteSchedule(_ schedule: ScheduleDataModel) -> Promise<Void> {
        _schedules.value.removeAll { $0 == schedule }
        return .value
    }
}
