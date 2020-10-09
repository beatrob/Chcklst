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
            CreateChecklistViewModel.self,
            arguments: ChecklistPassthroughSubject.self, TemplateDataModel?.self,
            initializer: CreateChecklistViewModel.init
        )
        container.autoregister(
            CreateChecklistViewModel.self,
            arguments: ChecklistPassthroughSubject.self, TemplatePassthroughSubject.self,
            initializer: CreateChecklistViewModel.init
        )
        container.autoregister(
            CreateChecklistViewModel.self,
            name: CreateChecklistViewModel.Constants.fromTemplate,
            arguments: ChecklistPassthroughSubject.self, TemplatePassthroughSubject.self, TemplateDataModel.self,
            initializer: CreateChecklistViewModel.init
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
        container.autoregister(
            FinalizeChecklistViewModel.self,
            initializer: FinalizeChecklistViewModel.init
        )
        container.autoregister(InitializeAppViewModel.self, initializer: InitializeAppViewModel.init)
        container.autoregister(SelectTemplateViewModel.self, initializer: SelectTemplateViewModel.init)
        container.autoregister(
            FilterViewModel.self,
            argument: FilterPassthroughSubject.self,
            initializer: FilterViewModel.init
        )
    }
}
