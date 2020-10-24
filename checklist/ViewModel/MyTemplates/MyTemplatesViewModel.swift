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
    @Published var isAlertVisible = false
    
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
    private var alert: MyTemplatesAlert = .none {
        didSet {
            self.isAlertVisible = alert.isVisible
        }
    }
    var cancellables =  Set<AnyCancellable>()
    
    var actionSheetView: ActionSheet { actionSheet.actionSheet }
    var sheetView: AnyView { sheet.view }
    var alertView: Alert { alert.alert }
    
    let onTemplateTapped = TemplatePassthroughSubject()
    let navigationHelper: NavigationHelper
    
    init(
        templateDataSource: TemplateDataSource,
        checklistDataSource: ChecklistDataSource,
        navigationHelper: NavigationHelper
    ) {
        self.navigationHelper = navigationHelper
        templateDataSource.templates.sink { [weak self] templates in
            self?.templates = templates
        }.store(in: &cancellables)
        
        templateDataSource.selectedTemplate.dropFirst().sink { [weak self] template in
            guard let template = template else {
                return
            }
            self?.sheet = .editTemplate(
                template: template,
                update: templateDataSource.updateTemplate
            )
        }.store(in: &cancellables)
        
        let createChecklist = ChecklistPassthroughSubject()
        createChecklist.sink { checklist in
            checklistDataSource.createChecklist(checklist)
            .done { Logger.log.debug("Create checklist success \(checklist)") }
            .catch { $0.log(message: "Create checklist failed") }
        }.store(in: &cancellables)
        
        onTemplateTapped.sink { [weak self] template in
            self?.actionSheet = .templateActions(
                template: template,
                onCreateChecklist: {
                    guard let self = self else { return }
                    self.sheet = .createChecklist(template: template)
                },
                onEdit: { templateDataSource.selectedTemplate.send(template) },
                onDelete: {
                    withAnimation {
                        templateDataSource.deleteTemplate.send(template)
                    }
                }
            )
        }.store(in: &cancellables)
        
        checklistDataSource.checkLists.dropFirst().delay(for: .seconds(1.0), scheduler: RunLoop.main).sink { [weak self] _ in
                self?.alert = .createChecklistSucess(
                    onGotoDashboard: {
                        self?.navigationHelper.popToDashboard()
                    }
                )
        }.store(in: &self.cancellables)
    }
}
