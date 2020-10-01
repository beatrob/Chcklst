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
        
        onTemplateTapped.sink { template in
            navigationHelper.navigateToCreateChecklist(
                with: template,
                createChecklist: checklistDataSource.createNewChecklist,
                createTemplate: templateDataSource.createNewTemplate
            )
        }.store(in: &cancellables)
    }
}
