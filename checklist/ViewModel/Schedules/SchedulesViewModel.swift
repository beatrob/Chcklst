//
//  SchedulesViewModel.swift
//  checklist
//
//  Created by Robert Konczi on 5/5/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI
import Combine


class SchedulesViewModel: ObservableObject {
    
    var cancellables = Set<AnyCancellable>()
    let navBarViewModel = AppContext.resolver.resolve(BackButtonNavBarViewModel.self, argument: "Schedules")!
    var onBackTapped: EmptyPublisher {
        navBarViewModel.backButton.didTap.eraseToAnyPublisher()
    }
    private let scheduleDataSource: ScheduleDataSource
    @Published var cells: [ScheduleCellViewModel] = []
    
    init(scheduleDataSource: ScheduleDataSource) {
        self.scheduleDataSource = scheduleDataSource
        scheduleDataSource.schedules.sink { [weak self] schedules in
            self?.cells = schedules.map {
                ScheduleCellViewModel(schedule: $0)
            }
        }.store(in: &cancellables)
    }
}
