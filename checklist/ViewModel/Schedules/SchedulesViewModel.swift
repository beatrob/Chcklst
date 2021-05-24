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
    var templateCancellable: AnyCancellable?
    var scheduleDetailCancellables = Set<AnyCancellable>()
    let navBarViewModel = AppContext.resolver.resolve(BackButtonNavBarViewModel.self, argument: "Schedules")!
    var onBackTapped: EmptyPublisher {
        navBarViewModel.backButton.didTap.eraseToAnyPublisher()
    }
    private let scheduleDataSource: ScheduleDataSource
    let didSelectSchedule = PassthroughSubject<ScheduleCellViewModel, Never>()
    @Published var cells: [ScheduleCellViewModel] = []
    @Published var isSheetPresented = false
    @Published var sheet = AnyView.empty
    
    init(scheduleDataSource: ScheduleDataSource) {
        self.scheduleDataSource = scheduleDataSource
        scheduleDataSource.schedules.sink { [weak self] schedules in
            self?.cells = schedules.map {
                ScheduleCellViewModel(schedule: $0)
            }.sorted { left, right in
                left.scheduleDate < right.scheduleDate
            }
        }.store(in: &cancellables)
        
        let rightButton = NavBarChipButtonViewModel(title: nil, icon: Image(systemName: "plus"))
        rightButton.didTap.sink { [weak self] in
            self?.presentSelectTemplate()
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
                .merge(with: viewModel.didDeleteSchedule).sink {
                    #warning("TODO: Pop view")
                }.store(in: &self.scheduleDetailCancellables)
            
            #warning("TODO: Push view")
        }.store(in: &cancellables)
    }
    
    private func presentSelectTemplate() {
        let viewModel = AppContext.resolver.resolve(SelectTemplateViewModel.self)!
        sheet = AnyView(SelectTemplateView(viewModel: viewModel))
        
        let presenterSubject = PassthroughSubject<AnyView?, Never>()
        
        let templateSubject = TemplatePassthroughSubject()
        templateCancellable?.cancel()
        templateCancellable = templateSubject.sink { [weak self] temaplate in
            self?.presentScheduleDetail(template: temaplate, presenterSubject: presenterSubject)
        }
       
        viewModel.set(
            onTemplateTappedSubscriber: AnySubscriber(templateSubject),
            destinationPublisher: presenterSubject.eraseToAnyPublisher()
        )
        self.isSheetPresented = true
    }
    
    private func presentScheduleDetail(
        template: TemplateDataModel,
        presenterSubject: PassthroughSubject<AnyView?, Never>
    ) {
        let viewModel = AppContext.resolver.resolve(
            ScheduleDetailViewModel.self,
            argument: ScheduleDetailViewState.create(template: template)
        )!
        scheduleDetailCancellables.removeAll()
        
        viewModel.backButtonViewModel.didTap.sink {
            presenterSubject.send(nil)
        }.store(in: &scheduleDetailCancellables)
        
        viewModel.didCreateSchedule.sink { [weak self] in
            self?.isSheetPresented = false
            self?.sheet = .empty
        }.store(in: &scheduleDetailCancellables)
        
        presenterSubject.send(AnyView(ScheduleDetailView(viewModel: viewModel)))
    }
}
