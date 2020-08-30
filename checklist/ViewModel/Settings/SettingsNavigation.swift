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

enum SettingsNavigation {
    case none
    case myTemplates
    
    var view: AnyView {
        switch self {
        case .myTemplates:
            let viewModel = AppContext.resolver.resolve(MyTemplatesViewModel.self)!
            return AnyView(MyTemplatesView(viewModel: viewModel))
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
