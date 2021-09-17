//
//  CreateScheduleViewModel.swift
//  checklist
//
//  Created by Robert Konczi on 5/28/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Combine
import SwiftUI


class CreateScheduleViewModel: ObservableObject {
    
    let presentViewPublisher: AnyPublisher<AnyView, Never>
    let didCreateSchedulePublisher: EmptyPublisher
    var onGotoDashboard: EmptyPublisher {
        onGotoDashboardSubject.eraseToAnyPublisher()
    }
    
    private let onGotoDashboardSubject = EmptySubject()
    
    private let createScheduleBackButtonSubject = EmptySubject()
    private let didCreateScheduleSubject = EmptySubject()
    private var cancellables = Set<AnyCancellable>()
    private var tempCancellables = Set<AnyCancellable>()
    
    
    init(createPublisher: EmptyPublisher) {
        
        let onTemplateTappedSubject = TemplatePassthroughSubject()
        let presenterSubject = PassthroughSubject<AnyView?, Never>()
        let selectTemplateViewModel = AppContext.resolver.resolve(SelectTemplateViewModel.self)!
        selectTemplateViewModel.title = "Create Schedule"
        selectTemplateViewModel.descriptionText = "Select a Template to create a new Schedule"
        selectTemplateViewModel.set(
            onTemplateTappedSubscriber: AnySubscriber(onTemplateTappedSubject),
            destinationPublisher: presenterSubject.eraseToAnyPublisher()
        )
        selectTemplateViewModel.onGotoDashboard.subscribe(onGotoDashboardSubject).store(in: &cancellables)
        
        createScheduleBackButtonSubject
            .map { _ -> AnyView? in nil }
            .subscribe(presenterSubject)
            .store(in: &cancellables)
        
        self.presentViewPublisher = createPublisher.map {
            presenterSubject.send(nil)
            return AnyView(SelectTemplateView(viewModel: selectTemplateViewModel))
        }.eraseToAnyPublisher()
        self.didCreateSchedulePublisher = didCreateScheduleSubject.eraseToAnyPublisher()
        
        onTemplateTappedSubject
            .map { [unowned self] in
                self.tempCancellables.removeAll()
                let viewModel = AppContext.resolver.resolve(
                    ScheduleDetailViewModel.self,
                    argument: ScheduleDetailViewState.create(template: $0)
                )!
                viewModel.backButtonViewModel.didTap
                    .subscribe(self.createScheduleBackButtonSubject)
                    .store(in: &tempCancellables)
                viewModel.didCreateSchedule
                    .subscribe(self.didCreateScheduleSubject)
                    .store(in: &tempCancellables)
                return viewModel
            }
            .map {
                return AnyView(ScheduleDetailView(viewModel: $0))
            }
            .subscribe(presenterSubject)
            .store(in: &cancellables)
    }
}
