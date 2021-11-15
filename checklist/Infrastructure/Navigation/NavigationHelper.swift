//
//  NavigationHelper.swift
//  checklist
//
//  Created by Róbert Konczi on 07/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI
import Combine


class NavigationHelper: ObservableObject {
    
    enum Source {
        case dashboard
        case settings
    }
    
    enum DashboardSelection: String {
        case settings
        case about
        case checklistDetail
        case myTemplates
        case schedules
    }
    
    enum SettingsSelection: String {
        case myTemplates
    }
    
    @Published var dashboardSelection: DashboardSelection? = nil
    @Published var settingsSelection: SettingsSelection? = nil
    var dashboardDestination: AnyView = .empty
    var settingsDestination: AnyView = .empty
    var cancellables = Set<AnyCancellable>()
    
    func navigateToSettings() {
        let viewModel = AppContext.resolver.resolve(SettingsViewModel.self)!
        viewModel.onBackTapped.sink { [weak self] in
            self?.dashboardSelection = .none
        }.store(in: &cancellables)
        dashboardDestination = AnyView(SettingsView(viewModel: viewModel))
        dashboardSelection = .settings
    }
    
    func navigateToSchedules() {
        let viewModel = AppContext.resolver.resolve(SchedulesViewModel.self)!
        viewModel.onBackTapped.sink { [weak self] in
            self?.dashboardSelection = .none
        }.store(in: &cancellables)
        dashboardDestination = AnyView(SchedulesView(viewModel: viewModel))
        dashboardSelection = .schedules
    }
    
    func navigateToMyTemplates(source: Source) {
        let viewModel = AppContext.resolver.resolve(MyTemplatesViewModel.self)!
        viewModel.onBackTapped.sink { [weak self] in
            self?.dashboardSelection = .none
        }.store(in: &cancellables)
        viewModel.onGotoSchedules.sink { [weak self] in
            self?.popToDashboard()
            DispatchQueue.main.async {
                self?.navigateToSchedules()
            }
        }.store(in: &cancellables)
        switch source {
        case .dashboard:
            dashboardDestination = AnyView(MyTemplatesView(viewModel: viewModel))
            dashboardSelection = .myTemplates
        case .settings:
            settingsDestination = AnyView(MyTemplatesView(viewModel: viewModel))
            settingsSelection = .myTemplates
        }
    }
    
    func navigateToChecklistDetail(with checklist: ChecklistDataModel, shouldEdit: Bool) {
        guard !navigateToDebugViewIfNeeded(with: checklist) else {
            return
        }
        let viewModel = AppContext.resolver.resolve(
            ChecklistViewModel.self,
            argument: shouldEdit ?
                ChecklistViewState.updateChecklist(checklist: checklist) :
                ChecklistViewState.display(checklist: checklist)
        )!
        viewModel.dismissView.sink { [weak self] in
            self?.popToDashboard()
        }.store(in: &cancellables)
        dashboardDestination = AnyView(ChecklistView(viewModel: viewModel))
        dashboardSelection = .checklistDetail
    }
    
    func navigateToAbout() {
        let viewModel = AppContext.resolver.resolve(AboutViewModel.self)!
        viewModel.navbarViewModel.backButton.didTap.sink { [weak self] in
            self?.dashboardSelection = .none
        }.store(in: &cancellables)
        dashboardDestination = AnyView(AboutView(viewModel: viewModel))
        dashboardSelection = .about
    }
    
    func popToDashboard() {
        dashboardSelection = nil
        settingsSelection = nil
        dashboardDestination = .empty
        settingsDestination = .empty
    }
    
    var isOnDashboard: Bool {
        dashboardSelection == .none
    }
}

private extension NavigationHelper {
    
    func navigateToDebugViewIfNeeded(with checklist: ChecklistDataModel) -> Bool {
        if checklist.title == DebugNotificationsViewModel.id {
            let viewModel = AppContext.resolver.resolve(DebugNotificationsViewModel.self)!
            viewModel.navbar.backButton.didTap.sink { [weak self] in
                self?.popToDashboard()
            }.store(in: &cancellables)
            dashboardDestination = AnyView(DebugNotificationsView(viewModel: viewModel))
            dashboardSelection = .checklistDetail
            return true
        }
        return false
    }
}
