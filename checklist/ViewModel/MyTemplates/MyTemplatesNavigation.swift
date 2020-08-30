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

enum MyTemplatesNavigation {
    case none
    case edit(template: TemplateCurrentValueSubject)
    
    var view: AnyView {
        switch self {
        case .edit(let template):
            let viewModel = AppContext.resolver.resolve(
                EditTemplateViewModel.self,
                argument: template
            )!
            return AnyView(EditTemplateView(viewModel: viewModel))
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
