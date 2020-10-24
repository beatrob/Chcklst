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
    let onTemplateTapped = TemplatePassthroughSubject()
    
    var cancellables =  Set<AnyCancellable>()
    
    init(
        checklistDataSource: ChecklistDataSource,
        templateDataSource: TemplateDataSource,
        navigationHelper: NavigationHelper
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
        
        onTemplateTapped.sink { template in
            navigationHelper.navigateToCreateChecklist(with: template)
        }.store(in: &cancellables)
    }
}
