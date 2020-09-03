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
    @Published var isActionSheetVisible = false
    @Published var isViewToNavigateVisible = false
    @Published var isSheetVisible = false
    
    private var actionSheet: MyTemplatesActionSheet = .none {
        didSet {
            self.isActionSheetVisible = actionSheet.isActionSheetVisible
        }
    }
    private var sheet: MyTemaplatesSheet = .none {
        didSet {
            self.isSheetVisible = sheet.isVisible
        }
    }
    var cancellables =  Set<AnyCancellable>()
    var actionSheetView: ActionSheet { actionSheet.actionSheet }
    var sheetView: AnyView { sheet.view }
    var viewToNavigate: AnyView { navigation.view }
    var navigation: MyTemplatesNavigation = .none {
        didSet {
            self.isViewToNavigateVisible = navigation.isViewVisible
        }
    }
    
    let onTemplateTapped = TemplatePassthroughSubject()
    
    init(
        templateDataSource: TemplateDataSource,
        checklistDataSource: ChecklistDataSource
    ) {
        templateDataSource.templates.sink { [weak self] templates in
            self?.templates = templates
        }.store(in: &cancellables)
        
        templateDataSource.selectedTemplate.dropFirst().sink { [weak self] _ in
            self?.navigation = .edit(template: templateDataSource.selectedTemplate)
        }.store(in: &cancellables)
        
        onTemplateTapped.sink { [weak self] template in
            self?.actionSheet = .templateActions(
                template: template,
                onCreateChecklist: {
                    self?.sheet = .createChecklist(
                        dataSource: checklistDataSource,
                        template: template
                    )
                },
                onEdit: { },
                onDelete: {
                    withAnimation {
                        templateDataSource.deleteTemplate.send(template)
                    }
                }
            )
        }.store(in: &cancellables)
    }
}
