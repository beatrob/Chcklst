//
//  SelectTemplateViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 01/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


class SelectTemplateViewModel: ObservableObject {
    
    @Published var templates: [TemplateDataModel] = [] {
        didSet {
            isEmptyListViewVisible = templates.isEmpty
        }
    }
    
    @Published var isDestionationViewVisible = false
    @Published var isEmptyListViewVisible = false
    @Published var title: String?
    @Published var descriptionText: String?
    let onTemplateTapped = TemplatePassthroughSubject()
    let onGotoDashboard = EmptySubject()
    var desitnationView = AnyView.empty
    var cancellables =  Set<AnyCancellable>()
    var templateTappedCancellable: AnyCancellable?
    
    
    init(
        checklistDataSource: ChecklistDataSource,
        templateDataSource: TemplateDataSource
    ) {
        templateDataSource.templates.sink { [weak self] templates in
            self?.templates = templates
        }.store(in: &cancellables)
        
        templateTappedCancellable = onTemplateTapped.sink { [weak self] template in
            guard let self = self else {
                return
            }
            let viewModel = AppContext.resolver.resolve(
                ChecklistViewModel.self,
                argument: ChecklistViewState.createFromTemplate(template: template)
            )!
            self.desitnationView = AnyView(ChecklistView(viewModel: viewModel))
            self.isDestionationViewVisible = true
        }
    }
    
    func set(
        onTemplateTappedSubscriber: AnySubscriber<TemplateDataModel, Never>,
        destinationPublisher: AnyPublisher<AnyView?, Never>
    ) {
        templateTappedCancellable?.cancel()
        onTemplateTapped.subscribe(onTemplateTappedSubscriber)
        destinationPublisher.sink { [weak self] in
            guard let destination = $0 else {
                self?.isDestionationViewVisible = false
                return
            }
            self?.desitnationView = destination
            self?.isDestionationViewVisible = true
        }.store(in: &cancellables)
    }
}
