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
import PromiseKit


class SchedulesViewModel: ObservableObject {
    
    var cancellables = Set<AnyCancellable>()
    var templateCancellable: AnyCancellable?
    var scheduleDetailCancellables = Set<AnyCancellable>()
    let navBarViewModel = AppContext.resolver.resolve(BackButtonNavBarViewModel.self, argument: "Schedules")!
    var onBackTapped: EmptyPublisher {
        navBarViewModel.backButton.didTap.eraseToAnyPublisher()
    }
    let onCreateSchedule = EmptySubject()
    private let scheduleDataSource: ScheduleDataSource
    private let createScheduleViewModel: CreateScheduleViewModel
    let didSelectSchedule = PassthroughSubject<ScheduleCellViewModel, Never>()
    @Published var cells: [ScheduleCellViewModel] = [] {
        didSet {
            isEmptyListViewVisible = cells.isEmpty
        }
    }
    @Published var isSheetPresented = false
    @Published var sheet = AnyView.empty
    @Published var navigationDestination = AnyView.empty
    @Published var isNavigationActive = false
    @Published var isEmptyListViewVisible = false
    
    init(scheduleDataSource: ScheduleDataSource, notificationManager: NotificationManager) {
        
        let rightButton = NavBarChipButtonViewModel(title: nil, icon: Image(systemName: "plus"))
        onCreateSchedule.subscribe(rightButton.didTapSubject).store(in: &cancellables)
        
        self.scheduleDataSource = scheduleDataSource
        self.createScheduleViewModel = AppContext.resolver.resolve(
            CreateScheduleViewModel.self,
            argument: rightButton.didTap
        )!
        scheduleDataSource.schedules.sink { [weak self] in
            guard let self = self else {
                return
            }
            let schedules = $0.sorted { $0.scheduleDate < $1.scheduleDate }
            if !schedules.isEmpty && schedules.count == self.cells.count {
                schedules.enumerated().forEach {
                    self.cells[$0.offset].update(with: $0.element)
                }
                self.objectWillChange.send()
            } else {
                self.cells = schedules.map {
                    ScheduleCellViewModel(schedule: $0)
                }
            }
        }.store(in: &cancellables)
        
        createScheduleViewModel.presentViewPublisher.sink { [weak self] in
            self?.sheet = $0
            self?.isSheetPresented = true
        }.store(in: &cancellables)
        
        createScheduleViewModel
            .didCreateSchedulePublisher
            .sink { [weak self] in
                self?.isSheetPresented = false
                self?.sheet = .empty
            }.store(in: &cancellables)
        
        createScheduleViewModel.onGotoDashboard.sink { [weak self] in
            self?.isSheetPresented = false
            after(seconds: 0.5).done {
                self?.navBarViewModel.backButton.didTapSubject.send()
            }
        }.store(in: &cancellables)
        
        navBarViewModel.setRightButton(rightButton)
        
        didSelectSchedule.sink { [weak self] scheduleCell in
            guard let self = self else {
                return
            }
            let viewModel = AppContext.resolver.resolve(
                ScheduleDetailViewModel.self,
                argument: ScheduleDetailViewState.update(schedule: scheduleCell.schedule)
            )!
            self.scheduleDetailCancellables.removeAll()
            
            viewModel.backButtonViewModel.didTap
                .merge(with: viewModel.didUpdateSchedule)
                .merge(with: viewModel.didDeleteSchedule).sink { [weak self] in
                    self?.isNavigationActive = false
                }.store(in: &self.scheduleDetailCancellables)
            
            self.navigationDestination = AnyView(ScheduleDetailView(viewModel: viewModel))
            self.isNavigationActive = true
        }.store(in: &cancellables)
        
        notificationManager.deeplinkChecklistId
            .merge(with: notificationManager.deeplinkScheduleId)
            .sink { [weak self] _ in
                self?.isSheetPresented = false
                self?.sheet = .empty
            }
            .store(in: &cancellables)
    }
}
