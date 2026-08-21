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
    @Published var isScheduleDetailPresented = false
    @Published private(set) var scheduleDetailViewModel: ScheduleDetailViewModel?
    var dismissView: EmptyPublisher {
        dismissViewSubject.eraseToAnyPublisher()
    }

    private let presentViewSubject = PassthroughSubject<AnyView, Never>()
    private let dismissViewSubject = EmptySubject()
    private let didCreateScheduleSubject = EmptySubject()
    fileprivate let selectTemplateViewModel: SelectTemplateViewModel
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
        isScheduleDetailPresented = false
        scheduleDetailViewModel = nil
        presentViewSubject.send(
            AnyView(
                CreateScheduleFlowView(viewModel: self)
            )
        )
    }

    func selectTemplate(_ template: TemplateDataModel) {
        scheduleDetailCancellables.removeAll()
        let viewModel = AppContext.resolver.resolve(
            ScheduleDetailViewModel.self,
            argument: ScheduleDetailViewState.create(template: template)
        )!

        viewModel.backButtonViewModel.didTap
            .subscribe(dismissViewSubject)
            .store(in: &scheduleDetailCancellables)
        viewModel.didCreateSchedule
            .subscribe(didCreateScheduleSubject)
            .store(in: &scheduleDetailCancellables)

        scheduleDetailViewModel = viewModel
        isScheduleDetailPresented = true
    }

    func dismiss() {
        dismissViewSubject.send()
    }
}

private struct CreateScheduleFlowView: View {

    @ObservedObject var viewModel: CreateScheduleViewModel

    var body: some View {
        NavigationStack {
            SelectTemplateView(
                viewModel: viewModel.selectTemplateViewModel,
                onTemplateSelected: viewModel.selectTemplate,
                onClose: viewModel.dismiss
            )
            .navigationDestination(isPresented: $viewModel.isScheduleDetailPresented) {
                if let detailViewModel = viewModel.scheduleDetailViewModel {
                    ScheduleDetailView(
                        viewModel: detailViewModel,
                        createCloseButtonPlacement: .topBarTrailing
                    )
                }
            }
        }
    }
}
