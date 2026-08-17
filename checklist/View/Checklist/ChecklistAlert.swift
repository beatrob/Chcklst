//
//  ChecklistAlert.swift
//  checklist
//
//  Created by Róbert Konczi on 11.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI


enum ChecklistAlert {
    
    case notificationsDisabled
    case confirmDelete(onDelete: EmptyCompletion)
    case confirmMarkAllDone(onConfirm: EmptyCompletion)
    case confirmMarkAllUnDone(onConfirm: EmptyCompletion)
    case confirmTemplateReplacement(onReplace: EmptyCompletion, onCancel: EmptyCompletion)
    case templateCreated(onGoToTemplates: EmptyCompletion)
    case none
    
    var view: Alert {
        switch self {
        case .notificationsDisabled:
            return .getEnablePushNotifications()
        case .confirmDelete(let onDelete):
            return .getConfirmDeleteChecklist(onDelete: onDelete)
        case .confirmMarkAllDone(let onConfirm):
            return Alert(
                title: Text("Do you wish to mark all items done?"),
                message: nil,
                primaryButton: .default(Text("Mark all done"), action: onConfirm),
                secondaryButton: .cancel()
                )
        case .confirmMarkAllUnDone(let onConfirm):
            return Alert(
                title: Text("Do you wish to mark all items undone?"),
                message: nil,
                primaryButton: .default(Text("Mark all undone"), action: onConfirm),
                secondaryButton: .cancel()
                )
        case .confirmTemplateReplacement(let onReplace, let onCancel):
            return Alert(
                title: Text("Replace current checklist?"),
                message: Text("This will replace the title, description, and items with the selected template."),
                primaryButton: .destructive(Text("Replace"), action: onReplace),
                secondaryButton: .cancel(onCancel)
            )
        case .templateCreated(let onGoToTemplates):
            return .getTemplateCreated {
                onGoToTemplates()
            }
        case .none:
            return .empty
        }
    }
    
    var isVisible: Bool {
        switch self {
        case .none:
            return false
        default:
            return true
        }
    }
}
