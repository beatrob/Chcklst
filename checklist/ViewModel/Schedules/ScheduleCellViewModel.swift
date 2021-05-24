//
//  ScheduleCellViewModel.swift
//  checklist
//
//  Created by Robert Konczi on 5/5/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


class ScheduleCellViewModel: ObservableObject, Identifiable {
    
    @Published var title: String
    @Published var description: String?
    @Published var scheduleDate: String
    @Published var repeatFrequency: String?
    var cancellables = Set<AnyCancellable>()
    var id: String {
        schedule.id
    }
    let schedule: ScheduleDataModel
    
    init(schedule: ScheduleDataModel) {
        self.schedule = schedule
        self.title = schedule.title
        self.description = schedule.description
        self.scheduleDate = schedule.scheduleDate.formatedScheduleDate()
        self.repeatFrequency = schedule.repeatFrequency.title
    }
}
