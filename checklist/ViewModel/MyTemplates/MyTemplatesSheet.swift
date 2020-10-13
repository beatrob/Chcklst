//
//  MyTemplatesSheet.swift
//  checklist
//
//  Created by Róbert Konczi on 03/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI

enum MyTemaplatesSheet {
    case createChecklist(createChecklist: ChecklistPassthroughSubject, template: TemplateDataModel)
    case editTemplate(template: TemplateDataModel, update: TemplatePassthroughSubject)
    case none
    
    var isVisible: Bool {
        switch self {
        case .none: return false
        default: return true
        }
    }
    
    var view: AnyView {
        switch self {
        case .createChecklist(let createChecklist, let template):
            let viewModel = AppContext.resolver.resolve(
                CreateUpdateChecklistViewModel.self,
                arguments:
                    createChecklist,
                    TemplatePassthroughSubject(),
                    ChecklistViewModelInput.createFromTemplate(template: template)
            )!
            return AnyView(CreateUpdateChecklistView(viewModel: viewModel))
        case .editTemplate(let template, let update):
            let viewModel = AppContext.resolver.resolve(
                EditTemplateViewModel.self,
                arguments: template, update
            )!
            return AnyView(EditTemplateView(viewModel: viewModel))
        case .none: return AnyView(EmptyView())
        }
    }
}
