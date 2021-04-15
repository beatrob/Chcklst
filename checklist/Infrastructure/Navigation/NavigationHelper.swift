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
        case checklistDetail
        case myTemplates
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
    
    func navigateToMyTemplates(source: Source) {
        let viewModel = AppContext.resolver.resolve(MyTemplatesViewModel.self)!
        viewModel.onBackTapped.sink { [weak self] in
            self?.dashboardSelection = .none
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
    
    func navigateToChecklistDetail(with checklist: ChecklistDataModel) {
        let viewModel = AppContext.resolver.resolve(
            ChecklistViewModel.self,
            argument: ChecklistViewState.display(checklist: checklist)
        )!
        viewModel.onDismiss.sink { [weak self] in
            self?.popToDashboard()
        }.store(in: &cancellables)
        dashboardDestination = AnyView(ChecklistView(viewModel: viewModel))
        dashboardSelection = .checklistDetail
    }
    
    func popToDashboard() {
        dashboardSelection = nil
        settingsSelection = nil
        dashboardDestination = .empty
        settingsDestination = .empty
    }
}
