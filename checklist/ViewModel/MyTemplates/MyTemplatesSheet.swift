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
    case createChecklist(dataSource: ChecklistDataSource, template: TemplateDataModel)
    case none
    
    var isVisible: Bool {
        switch self {
        case .none: return false
        default: return true
        }
    }
    
    var view: AnyView {
        switch self {
        case .createChecklist(let dataSource, let template):
            let viewModel = AppContext.resolver.resolve(
                CreateChecklistViewModel.self,
                name: CreateChecklistViewModel.Constants.fromTemplate,
                arguments: dataSource.createNewChecklist, template
            )!
            return AnyView(CreateChecklistView(viewModel: viewModel))
        case .none: return AnyView(EmptyView())
        }
    }
}
