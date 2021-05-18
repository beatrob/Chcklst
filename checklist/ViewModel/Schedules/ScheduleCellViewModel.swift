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
    let id: String
    
    init(schedule: ScheduleDataModel) {
        self.id = schedule.id
        self.title = schedule.title
        self.description = schedule.description
        self.scheduleDate = schedule.scheduleDate.formatedScheduleDate()
        self.repeatFrequency = schedule.repeatFrequency.title
    }
}
