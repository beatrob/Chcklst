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
    var scheduleDetailCancellable: AnyCancellable?
    let navBarViewModel = AppContext.resolver.resolve(BackButtonNavBarViewModel.self, argument: "Schedules")!
    var onBackTapped: EmptyPublisher {
        navBarViewModel.backButton.didTap.eraseToAnyPublisher()
    }
    private let scheduleDataSource: ScheduleDataSource
    @Published var cells: [ScheduleCellViewModel] = []
    @Published var isSheetPresented = false
    @Published var sheet = AnyView.empty
    
    init(scheduleDataSource: ScheduleDataSource) {
        self.scheduleDataSource = scheduleDataSource
        scheduleDataSource.schedules.sink { [weak self] schedules in
            self?.cells = schedules.map {
                ScheduleCellViewModel(schedule: $0)
            }
        }.store(in: &cancellables)
        
        let rightButton = NavBarChipButtonViewModel(title: nil, icon: Image(systemName: "plus"))
        rightButton.didTap.sink { [weak self] in
            self?.presentSelectTemplate()
        }.store(in: &cancellables)
        navBarViewModel.setRightButton(rightButton)
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
        scheduleDetailCancellable?.cancel()
        scheduleDetailCancellable = viewModel.backButtonViewModel.didTap.sink {
            presenterSubject.send(nil)
        }
        presenterSubject.send(AnyView(ScheduleDetailView(viewModel: viewModel)))
    }
}
