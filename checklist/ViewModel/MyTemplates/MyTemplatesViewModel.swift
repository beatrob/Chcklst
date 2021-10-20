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
    
    @Published var templates: [TemplateDataModel] = [] {
        didSet {
            isEmptyViewVisible = templates.isEmpty
        }
    }
    @Published var isActionSheetVisible = false
    @Published var isViewToNavigateVisible = false
    @Published var isSheetVisible = false
    @Published var isAlertVisible = false
    @Published var isEmptyViewVisible = false
    @Published var isNavigationLinkActive = false
    @Published var navigationLinkDesitanation: AnyView = .empty
    
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
    var createScheduleViewModel: CreateScheduleViewModel?
    
    var actionSheetView: ActionSheet { actionSheet.actionSheet }
    var sheetView = AnyView(EmptyView())
    var alertView: Alert { alert.alert }
    
    let onGotoDashboard = EmptySubject()
    let onTemplateTapped = TemplatePassthroughSubject()
    let navigationHelper: NavigationHelper
    let navBarViewModel = AppContext.resolver.resolve(
        BackButtonNavBarViewModel.self,
        argument: "Templates"
    )!
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
            .done { _ in Logger.log.debug("Create checklist success \(checklist)") }
            .catch { $0.log(message: "Create checklist failed") }
        }.store(in: &cancellables)
        
        onTemplateTapped.sink { [weak self] template in
            self?.actionSheet = .templateActions(
                template: template,
                onCreateChecklist: {
                    self?.displayCreateChecklist(template)
                },
                onCreateSchedule: {
                    self?.createSchedule(template)
                },
                onEdit: {
                    templateDataSource.selectedTemplate.send(template)
                },
                onDelete: {
                    guard let self = self else {
                        return
                    }
                    self.alert = .confirmDelete(onConfirm: {
                        templateDataSource.deleteTemplate(template).catch { error in
                            error.log(message: "Failed to delete template")
                        }
                    })
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
        
        onGotoDashboard.subscribe(navBarViewModel.backButton.didTapSubject).store(in: &cancellables)
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
    
    func createSchedule(_ template: TemplateDataModel) {
        
        let viewModel = AppContext.resolver.resolve(
            ScheduleDetailViewModel.self,
            argument: ScheduleDetailViewState.create(template: template)
        )!
        let view = ScheduleDetailView(viewModel: viewModel)
        sheetView = AnyView(view)
        isSheetVisible = true
        viewModel.didCreateSchedule.sink { [weak self] _ in
            self?.isSheetVisible = false
            DispatchQueue.main.async {
                self?.alert = .createScheduleSuccess(onGotoSchedules: {
                    DispatchQueue.main.async {
                        self?.openSchedules()
                    }
                })
            }
        }.store(in: &cancellables)
    }
    
    func openSchedules() {
        let viewModel = AppContext.resolver.resolve(SchedulesViewModel.self)!
        let view = SchedulesView(viewModel: viewModel)
        viewModel.onBackTapped.sink { [weak self] in
            self?.navigationLinkDesitanation = .empty
            self?.isNavigationLinkActive = false
        }.store(in: &cancellables)
        self.navigationLinkDesitanation = AnyView(view)
        self.isNavigationLinkActive = true
    }
}
