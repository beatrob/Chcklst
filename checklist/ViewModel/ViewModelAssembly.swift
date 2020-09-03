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
            ChecklistViewModel.self,
            argument: ChecklistCurrentValueSubject.self,
            initializer: ChecklistViewModel.init
        )
        container.autoregister(
            CreateChecklistViewModel.self,
            arguments: ChecklistPassthroughSubject.self, TemplateDataModel?.self,
            initializer: CreateChecklistViewModel.init
        )
        container.autoregister(
            CreateChecklistViewModel.self,
            argument: ChecklistPassthroughSubject.self,
            initializer: CreateChecklistViewModel.init
        )
        container.autoregister(
            CreateChecklistViewModel.self,
            name: CreateChecklistViewModel.Constants.fromTemplate,
            arguments: ChecklistPassthroughSubject.self, TemplateDataModel.self,
            initializer: CreateChecklistViewModel.init
        )
        container.autoregister(MyTemplatesViewModel.self, initializer: MyTemplatesViewModel.init)
        container.autoregister(
            EditTemplateViewModel.self,
            argument: TemplateCurrentValueSubject.self,
            initializer: EditTemplateViewModel.init
        )
    }
}
