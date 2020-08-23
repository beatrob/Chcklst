//
//  DashboardNavigation.swift
//  checklist
//
//  Created by Róbert Konczi on 23/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

enum DashboardNavigation {
    case none
    case checklistDetail(checklist: ChecklistCurrentValueSubject)
    case settings
    
    var view: AnyView {
        switch self {
        case .checklistDetail(let checklist):
            let viewModel = AppContext.resolver.resolve(
                ChecklistViewModel.self,
                argument: checklist
            )!
            return AnyView(ChecklistView(viewModel: viewModel))
        case .settings:
            let viewModel = AppContext.resolver.resolve(SettingsViewModel.self)!
            return AnyView(SettingsView(viewModel: viewModel))
        default:
            return AnyView(EmptyView())
        }
    }
    
    var isViewVisible: Bool {
        switch self {
        case .none: return false
        default: return true
        }
    }
}
