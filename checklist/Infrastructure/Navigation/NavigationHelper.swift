//
//  NavigationHelper.swift
//  checklist
//
//  Created by Róbert Konczi on 07/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI

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
    
    enum SelectTemplateSelection: String {
        case createChecklist
    }
    
    @Published var dashboardSelection: DashboardSelection? = nil
    @Published var settingsSelection: SettingsSelection? = nil
    @Published var selectTemplateSelection: SelectTemplateSelection? = nil
    var dashboardDestination: AnyView = .empty
    var settingsDestination: AnyView = .empty
    var selectTemplateDestination: AnyView = .empty
    
    func navigateToSettings() {
        let viewModel = AppContext.resolver.resolve(SettingsViewModel.self)!
        dashboardDestination = AnyView(SettingsView(viewModel: viewModel))
        dashboardSelection = .settings
    }
    
    func navigateToMyTemplates(source: Source) {
        let viewModel = AppContext.resolver.resolve(MyTemplatesViewModel.self)!
        switch source {
        case .dashboard:
            dashboardDestination = AnyView(MyTemplatesView(viewModel: viewModel))
            dashboardSelection = .myTemplates
        case .settings:
            settingsDestination = AnyView(MyTemplatesView(viewModel: viewModel))
            settingsSelection = .myTemplates
        }
    }
    
    func navigateToChecklistDetail(with checklist: ChecklistCurrentValueSubject) {
        let viewModel = AppContext.resolver.resolve(
            ChecklistViewModel.self,
            argument: checklist
        )!
        dashboardDestination = AnyView(ChecklistView(viewModel: viewModel))
        dashboardSelection = .checklistDetail
    }
    
    func navigateToCreateChecklist(
        with template: TemplateDataModel,
        createChecklist: ChecklistPassthroughSubject,
        createTemplate: TemplatePassthroughSubject
    ) {
        let viewModel = AppContext.resolver.resolve(
            CreateChecklistViewModel.self,
            name: CreateChecklistViewModel.Constants.fromTemplate,
            arguments: createChecklist, createTemplate, template
        )!
        selectTemplateDestination = AnyView(CreateChecklistView(viewModel: viewModel))
        selectTemplateSelection = .createChecklist
    }
    
    func popToDashboard() {
        dashboardSelection = nil
        settingsSelection = nil
        dashboardDestination = .empty
        settingsDestination = .empty
    }
}
