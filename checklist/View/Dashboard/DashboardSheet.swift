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
    case createChecklist(viewModel: ChecklistViewModel)
    
    var view: AnyView {
        switch self {
        case .createChecklist(let viewModel):
            return AnyView(
                NavigationStack {
                    ChecklistView(viewModel: viewModel)
                }
            )
        }
    }
    
}
