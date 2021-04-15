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

    private var alert: MyTemplatesAlert = .none {
        didSet {
            self.isAlertVisible = alert.isVisible
        }
    }
    var cancellables =  Set<AnyCancellable>()
    
    var actionSheetView: ActionSheet { actionSheet.actionSheet }
    var sheetView = AnyView(EmptyView())
    var alertView: Alert { alert.alert }
    
    let onTemplateTapped = TemplatePassthroughSubject()
    let navigationHelper: NavigationHelper
    let navBarViewModel = TemplatesNavBarViewModel()
    var onBackTapped: EmptyPublisher {
        navBarViewModel.backButton.didTap.eraseToAnyPublisher()
    }
    
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
            self?.displayEditTemplate(template)
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
                    self?.displayCreateChecklist(template)
                },
                onEdit: {
                    templateDataSource.selectedTemplate.send(template)
                },
                onDelete: {
                    templateDataSource.deleteTemplate(template).catch { error in
                        error.log(message: "Failed to delete template")
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


private extension MyTemplatesViewModel {
    
    func displayEditTemplate(_ template: TemplateDataModel) {
        let viewModel = AppContext.resolver.resolve(
            ChecklistViewModel.self,
            argument: ChecklistViewState.updateTemplate(template: template)
        )!
        viewModel.onDidUpdateTemplate.sink { [weak self] in
            self?.isSheetVisible = false
        }.store(in: &cancellables)
        sheetView = AnyView(ChecklistView(viewModel: viewModel))
        isSheetVisible = true
    }
    
    func displayCreateChecklist(_ template: TemplateDataModel) {
        let viewModel = AppContext.resolver.resolve(
            ChecklistViewModel.self,
            argument: ChecklistViewState.createFromTemplate(template: template)
        )!
        sheetView = AnyView(ChecklistView(viewModel: viewModel))
        isSheetVisible = true
    }
}
