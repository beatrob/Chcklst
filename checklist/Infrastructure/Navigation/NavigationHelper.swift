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

    enum AppTab: Hashable {
        case checklists
        case templates
        case schedules
        case settings
    }

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

    @Published var selectedTab: AppTab = .checklists
    @Published var dashboardSelection: DashboardSelection? = nil
    @Published var settingsSelection: SettingsSelection? = nil
    var dashboardDestination: AnyView = .empty
    var settingsDestination: AnyView = .empty
    var cancellables = Set<AnyCancellable>()

    func navigateToSettings() {
        selectedTab = .settings
    }

    func navigateToSchedules() {
        selectedTab = .schedules
    }

    func navigateToMyTemplates(source: Source) {
        switch source {
        case .dashboard, .settings:
            selectedTab = .templates
        }
    }

    func navigateToChecklistDetail(with checklist: ChecklistDataModel, shouldEdit: Bool) {
        guard !navigateToDebugViewIfNeeded(with: checklist) else {
            return
        }
        selectedTab = .checklists
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
        selectedTab = .checklists
        let viewModel = AppContext.resolver.resolve(AboutViewModel.self)!
        viewModel.navbarViewModel.backButton.didTap.sink { [weak self] in
            self?.dashboardSelection = .none
        }.store(in: &cancellables)
        dashboardDestination = AnyView(AboutView(viewModel: viewModel))
        dashboardSelection = .about
    }

    func popToDashboard() {
        selectedTab = .checklists
        dashboardSelection = nil
        settingsSelection = nil
        dashboardDestination = .empty
        settingsDestination = .empty
    }

    var isOnDashboard: Bool {
        selectedTab == .checklists && dashboardSelection == .none
    }
}

private extension NavigationHelper {

    func navigateToDebugViewIfNeeded(with checklist: ChecklistDataModel) -> Bool {
        if checklist.title == DebugNotificationsViewModel.id {
            selectedTab = .checklists
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
