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
    case createChecklist(viewModel: ChecklistViewModel)
    case createTemplate(viewModel: ChecklistViewModel)
    case selectTemplate(viewModel: SelectTemplateViewModel)
    case editReminder(viewModel: EditReminderViewModel)
    case menu
    
    var view: AnyView {
        switch self {
        case .createChecklist(let viewModel), .createTemplate(let viewModel):
            return AnyView(ChecklistView(viewModel: viewModel))
        case .selectTemplate(let viewModel):
            return AnyView(
                SelectTemplateView(viewModel: viewModel)
                    .environmentObject(AppContext.resolver.resolve(NavigationHelper.self)!)
            )
        case .menu:
            return AnyView(
                MenuView(viewModel: AppContext.resolver.resolve(MenuViewModel.self)!)
            )
        case .editReminder(let viewModel):
            return AnyView(
                EditReminderView(viewModel: viewModel)
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
