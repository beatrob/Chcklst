//
//  MyTemplatesAlert.swift
//  checklist
//
//  Created by Róbert Konczi on 07/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


enum MyTemplatesAlert {
    
    case createChecklistSucess(onGotoDashboard: EmptyCompletion)
    case createScheduleSuccess(onGotoSchedules: EmptyCompletion)
    case confirmDelete(onConfirm: EmptyCompletion)
    case none
    
    var alert: Alert {
        switch self {
        case .createChecklistSucess(let onGotoDashboard):
            return Alert(
                title: Text("New Checklist created"),
                primaryButton: .default(Text("Go to Dashboard"), action: onGotoDashboard),
                secondaryButton: .cancel()
            )
        case .createScheduleSuccess(let onGotoSchedules):
            return Alert(
                title: Text("New Schedule created"),
                primaryButton: .default(Text("Go to Schedules"), action: onGotoSchedules),
                secondaryButton: .cancel()
            )
        case .confirmDelete(let onConfirm):
            return Alert(
                title: Text("Do you really want to delete this template?"),
                primaryButton: .destructive(Text("Delete"), action: onConfirm),
                secondaryButton: .cancel()
            )
        case .none:
            return .empty
        }
    }
    
    var isVisible: Bool {
        switch self {
        case .none: return false
        default: return true
        }
    }
    
}
