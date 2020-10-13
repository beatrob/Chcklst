//
//  DashboardSheet.swift
//  checklist
//
//  Created by Róbert Konczi on 15/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

enum DashboardSheet {
    
    case none
    case createChecklist(
        createNewChecklist: ChecklistPassthroughSubject,
        createNewTemplate: TemplatePassthroughSubject
    )
    case selectTemplate
    
    var view: AnyView {
        switch self {
        case .createChecklist(let createNewChecklist, let createNewTemplate):
            return AnyView(
                CreateUpdateChecklistView(
                    viewModel: AppContext.resolver.resolve(
                        CreateUpdateChecklistViewModel.self,
                        argument:
                            ChecklistViewModelInput(
                                createChecklistSubject: createNewChecklist,
                                createTemplateSubject: createNewTemplate,
                                action: .createNew
                            )
                        )!
                )
            )
        case .selectTemplate:
            return AnyView(
                SelectTemplateView(viewModel: AppContext.resolver.resolve(SelectTemplateViewModel.self)!)
                    .environmentObject(AppContext.resolver.resolve(NavigationHelper.self)!)
            )
        case .none: return AnyView.empty
        }
    }
    
    var isVisible: Bool {
        switch self {
        case .none: return false
        default: return true
        }
    }
    
}
