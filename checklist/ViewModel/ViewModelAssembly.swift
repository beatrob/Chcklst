//
//  ViewModelAssembly.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Swinject
import SwinjectAutoregistration
import Combine

class ViewModelAssembly: Assembly {
    
    func assemble(container: Container) {
        container.autoregister(DashboardViewModel.self, initializer: DashboardViewModel.init)
        container.autoregister(SettingsViewModel.self, initializer: SettingsViewModel.init)
        container.autoregister(
            ChecklistDetailViewModel.self,
            argument: ChecklistCurrentValueSubject.self,
            initializer: ChecklistDetailViewModel.init
        )
        container.autoregister(
            ChecklistViewModel.self,
            arguments: ChecklistPassthroughSubject.self, TemplateDataModel?.self,
            initializer: ChecklistViewModel.init
        )
        container.autoregister(
            ChecklistViewModel.self,
            argument: ChecklistViewState.self,
            initializer: ChecklistViewModel.init
        )
        container.autoregister(
            MyTemplatesViewModel.self,
            initializer: MyTemplatesViewModel.init
        )
        container.autoregister(
            EditTemplateViewModel.self,
            arguments: TemplateDataModel.self, TemplatePassthroughSubject.self,
            initializer: EditTemplateViewModel.init
        )
        container.autoregister(InitializeAppViewModel.self, initializer: InitializeAppViewModel.init)
        container.autoregister(SelectTemplateViewModel.self, initializer: SelectTemplateViewModel.init)
        container.autoregister(MenuViewModel.self, initializer: MenuViewModel.init)
        container.autoregister(DashboardNavBarViewModel.self, initializer: DashboardNavBarViewModel.init)
        container.autoregister(
            ChecklistNavBarViewModel.self,
            argument: AnyPublisher<ChecklistDataModel?, Never>.self,
            initializer: ChecklistNavBarViewModel.init
        )
        container.autoregister(
            EditReminderViewModel.self,
            argument: ChecklistDataModel.self,
            initializer: EditReminderViewModel.init
        )
    }
}
