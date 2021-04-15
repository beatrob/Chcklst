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
    
    @Published var templates: [TemplateDataModel] = []
    @Published var isDestionationViewVisible = false
    let onTemplateTapped = TemplatePassthroughSubject()
    var desitnationView = AnyView(EmptyView())
    var cancellables =  Set<AnyCancellable>()
    
    
    init(
        checklistDataSource: ChecklistDataSource,
        templateDataSource: TemplateDataSource
    ) {
        templateDataSource.templates.sink { [weak self] templates in
            self?.templates = templates
        }.store(in: &cancellables)
        
        let createChecklist = ChecklistPassthroughSubject()
        createChecklist.sink { checklist in
            checklistDataSource.createChecklist(checklist)
            .done { Logger.log.debug("Chekclist created \(checklist)")}
            .catch { $0.log(message: "Failed to create checklist") }
        }.store(in: &cancellables)
        
        onTemplateTapped.sink { [weak self] template in
            guard let self = self else {
                return
            }
            let viewModel = AppContext.resolver.resolve(
                ChecklistViewModel.self,
                argument: ChecklistViewState.createFromTemplate(template: template)
            )!
            self.desitnationView = AnyView(ChecklistView(viewModel: viewModel))
            self.isDestionationViewVisible = true
        }.store(in: &cancellables)
    }
}
