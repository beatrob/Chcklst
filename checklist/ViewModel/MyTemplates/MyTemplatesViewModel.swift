//
//  MyTemplatesViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 30/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


class MyTemplatesViewModel: ObservableObject {
    
    @Published var templates: [TemplateDataModel] = []
    @Published var isActionSheetVisible: Bool = false
    @Published var isViewToNavigateVisible = false
    
    private var actionSheet: MyTemplatesActionSheet = .none {
        didSet {
            self.isActionSheetVisible = actionSheet.isActionSheetVisible
        }
    }
    var cancellables =  Set<AnyCancellable>()
    var actionSheetView: ActionSheet {
        actionSheet.actionSheet
    }
    var viewToNavigate: AnyView { navigation.view }
    var navigation: MyTemplatesNavigation = .none {
        didSet {
            self.isViewToNavigateVisible = navigation.isViewVisible
        }
    }
    
    let onTemplateTapped = TemplatePassthroughSubject()
    let onTemplateLongTapped = TemplatePassthroughSubject()
    
    init(templateDataSource: TemplateDataSource) {
        templateDataSource.templates.sink { [weak self] templates in
            self?.templates = templates
        }.store(in: &cancellables)
        
        templateDataSource.selectedTemplate.dropFirst().sink { [weak self] _ in
            self?.navigation = .edit(template: templateDataSource.selectedTemplate)
        }.store(in: &cancellables)
        
        onTemplateTapped.sink { template in
            templateDataSource.selectedTemplate.send(template)
        }.store(in: &cancellables)
        
        onTemplateLongTapped.sink { [weak self] template in
            self?.actionSheet = .templateActions(
                template: template,
                onCreateChecklist: { },
                onDelete: { }
            )
        }.store(in: &cancellables)
    }
}
