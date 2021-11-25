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
    
    let onGotoSchedules = EmptySubject()
    
    init(
        templateDataSource: TemplateDataSource,
        checklistDataSource: ChecklistDataSource,
        navigationHelper: NavigationHelper,
        notificationManager: NotificationManager
    ) {
        self.navigationHelper = navigationHelper
        
        let createButton = NavBarChipButtonViewModel(title: nil, icon: Image(systemName: "plus"))
        createButton.didTap.sink { [weak self] in
            self?.displayCreate(nil)
        }.store(in: &cancellables)
        self.navBarViewModel.setRightButton(createButton)
        
        templateDataSource.templates.sink { [weak self] templates in
            self?.templates = templates.sorted(by: { left, right in
                left.created > right.created
            })
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
                    self?.displayCreate(template)
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
        
        notificationManager.deeplinkChecklistId
            .merge(with: notificationManager.deeplinkScheduleId)
            .sink { [weak self] _ in
                self?.isSheetVisible = false
                self?.sheetView = .empty
            }
            .store(in: &cancellables)
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
        viewModel.dismissView.sink { [weak self] in
            self?.sheetView = .empty
            self?.isSheetVisible = false
        }.store(in: &cancellables)
        viewModel.setBigTitleNavBar(isTransparent: true)
        sheetView = AnyView(ChecklistView(viewModel: viewModel))
        isSheetVisible = true
    }
    
    func displayCreate(_ template: TemplateDataModel?) {
        let viewState: ChecklistViewState = template == nil ?
            .createTemplate :
            .createChecklistFromTemplate(template: template!)
        let viewModel = AppContext.resolver.resolve(
            ChecklistViewModel.self,
            argument: viewState
        )!
        viewModel.setBigTitleNavBar(isTransparent: true)
        viewModel.dismissView.sink { [weak self] in
            self?.sheetView = .empty
            self?.isSheetVisible = false
        }.store(in: &cancellables)
        sheetView = AnyView(ChecklistView(viewModel: viewModel))
        isSheetVisible = true
    }
    
    func createSchedule(_ template: TemplateDataModel) {
        
        let viewModel = AppContext.resolver.resolve(
            ScheduleDetailViewModel.self,
            argument: ScheduleDetailViewState.create(template: template)
        )!
        viewModel.isBackButtonVisible = false
        let view = ScheduleDetailView(viewModel: viewModel)
        sheetView = AnyView(view)
        isSheetVisible = true
        viewModel.didCreateSchedule.sink { [weak self] _ in
            self?.isSheetVisible = false
            DispatchQueue.main.async {
                self?.alert = .createScheduleSuccess(onGotoSchedules: {
                    DispatchQueue.main.async {
                        self?.onGotoSchedules.send()
                    }
                })
            }
        }.store(in: &cancellables)
    }
}
