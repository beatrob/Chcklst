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
    
    static let mockData: [ScheduleDataModel] = [
        ScheduleDataModel(
            id: "1",
            title: "My first schedule",
            description: "This is my first schedule to do stuff regularly and improve productivity.",
            template: .init(checklist: .getWelcomeChecklist()),
            scheduleDate: Date().addingTimeInterval(60 * 60 * 24),
            repeatFrequency: .weekly
        ),
        ScheduleDataModel(
            id: "2",
            title: "My second schedule",
            description: nil,
            template: .init(checklist: .getWelcomeChecklist()),
            scheduleDate: Date().addingTimeInterval(60 * 60 * 24 * 3),
            repeatFrequency: .daily
        ),
        ScheduleDataModel(
            id: "3",
            title: "My third schedule",
            description: nil,
            template: .init(checklist: .getWelcomeChecklist()),
            scheduleDate: Date().addingTimeInterval(60 * 60 * 24 * 4),
            repeatFrequency: .customDays(days: [.monday, .thursday, .saturday])
        ),
    ]
    
    private let _schedules = CurrentValueSubject<[ScheduleDataModel], Never>([])
    var schedules: AnyPublisher<[ScheduleDataModel], Never> {
        _schedules.eraseToAnyPublisher()
    }
    
    func loadAllSchedules() -> Promise<[ScheduleDataModel]> {
        _schedules.value = Self.mockData
        return .value(Self.mockData)
    }
    
    func createSchedule(_ schedule: ScheduleDataModel) -> Promise<ScheduleDataModel> {
        _schedules.value.append(schedule)
        return .value(schedule)
    }
    
    func updateSchedule(_ schedule: ScheduleDataModel) -> Promise<Void> {
        if let i = _schedules.value.firstIndex(of: schedule) {
            _schedules.value.replaceSubrange(i...i, with: [schedule])
        }
        return .value
    }
    
    func deleteSchedule(_ schedule: ScheduleDataModel) -> Promise<Void> {
        _schedules.value.removeAll { $0 == schedule }
        return .value
    }
    
    func getSchedule(with identifier: String) -> Promise<ScheduleDataModel> {
        if let schedule = _schedules.value.first(where: { $0.id == identifier }) {
            return .value(schedule)
        }
        return .init(error: DataSourceError.scheduleNotFound)
    }
}
