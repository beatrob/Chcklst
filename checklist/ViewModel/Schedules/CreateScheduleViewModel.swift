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
    var dismissView: EmptyPublisher {
        dismissViewSubject.eraseToAnyPublisher()
    }

    private let presentViewSubject = PassthroughSubject<AnyView, Never>()
    private let dismissViewSubject = EmptySubject()
    private let didCreateScheduleSubject = EmptySubject()
    private let selectTemplateViewModel: SelectTemplateViewModel
    private var cancellables = Set<AnyCancellable>()
    private var scheduleDetailCancellables = Set<AnyCancellable>()

    init(createPublisher: EmptyPublisher) {
        self.selectTemplateViewModel = AppContext.resolver.resolve(SelectTemplateViewModel.self)!
        self.presentViewPublisher = presentViewSubject.eraseToAnyPublisher()
        self.didCreateSchedulePublisher = didCreateScheduleSubject.eraseToAnyPublisher()

        createPublisher.sink { [weak self] in
            self?.showTemplatePicker()
        }.store(in: &cancellables)
    }

    private func showTemplatePicker() {
        presentViewSubject.send(
            AnyView(
                SelectTemplateView(
                    viewModel: selectTemplateViewModel,
                    onTemplateSelected: { [weak self] template in
                        self?.showScheduleDetail(for: template)
                    },
                    onClose: { [weak self] in
                        self?.dismissViewSubject.send()
                    }
                )
            )
        )
    }

    private func showScheduleDetail(for template: TemplateDataModel) {
        scheduleDetailCancellables.removeAll()
        let viewModel = AppContext.resolver.resolve(
            ScheduleDetailViewModel.self,
            argument: ScheduleDetailViewState.create(template: template)
        )!

        viewModel.backButtonViewModel.didTap
            .sink { [weak self] in self?.showTemplatePicker() }
            .store(in: &scheduleDetailCancellables)
        viewModel.didCreateSchedule
            .subscribe(didCreateScheduleSubject)
            .store(in: &scheduleDetailCancellables)

        presentViewSubject.send(AnyView(ScheduleDetailView(viewModel: viewModel)))
    }
}
