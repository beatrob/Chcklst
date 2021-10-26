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
    case scheduleCreated(gotoSchedules: EmptyCompletion)
    case confirmDeleteChecklist(onDelete: EmptyCompletion)
    case confirmMarkAllItemsDone(onConfirm: EmptyCompletion)
    case confirmMarkAllItemsUnDone(onConfirm: EmptyCompletion)
    
    var view: Alert {
        switch self {
        case .templateCreated(let gotoTemplates):
            return Alert.getTemplateCreated {
                gotoTemplates()
            }
        case .confirmDeleteChecklist(let onDelete):
            return .getConfirmDeleteChecklist(onDelete: onDelete)
        case .scheduleCreated(let gotoSchedules):
            return Alert(
                title: Text("Schedule created"),
                message: Text("Do you want to open your schedules?"),
                primaryButton: .default(Text("Go to schedules"), action: {
                    gotoSchedules()
                }),
                secondaryButton: .cancel()
            )
        case .none: return .empty
        case .confirmMarkAllItemsDone(let onConfirm):
            return ChecklistAlert.confirmMarkAllDone(onConfirm: onConfirm).view
        case .confirmMarkAllItemsUnDone(let onConfirm):
            return ChecklistAlert.confirmMarkAllUnDone(onConfirm: onConfirm).view
        }
    }
    
    var isVisible: Bool {
        switch self {
        case .none: return false
        default: return true
        }
    }
    
}
