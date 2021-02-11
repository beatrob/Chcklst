//
//  DashboardAlert.swift
//  checklist
//
//  Created by Róbert Konczi on 23/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

enum DashboardAlert {
    
    case none
    case templateCreated(gotoTemplates: EmptyCompletion)
    case confirmDeleteChecklist(onDelete: EmptyCompletion)
    
    var view: Alert {
        switch self {
        case .templateCreated(let gotoTemplates):
            return Alert(
                title: Text("Template created"),
                message: Text("Do you want to see your templates?"),
                primaryButton: .default(Text("Yes"), action: gotoTemplates),
                secondaryButton: .cancel(Text("No"))
            )
        case .confirmDeleteChecklist(let onDelete):
            return Alert(
                title: Text("Delete"),
                message: Text("Do you really want to delete this checklist?"),
                primaryButton: .default(Text("Delete"), action: onDelete),
                secondaryButton: .cancel(Text("Cancel"))
            )
        case .none: return .empty
        }
    }
    
    var isVisible: Bool {
        switch self {
        case .none: return false
        default: return true
        }
    }
    
}
