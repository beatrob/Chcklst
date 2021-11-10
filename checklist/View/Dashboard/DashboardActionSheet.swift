//
//  DashboardActionSheet.swift
//  checklist
//
//  Created by Róbert Konczi on 23/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

enum DashboardActionSheet {
    case editChecklist(checklist: ChecklistDataModel, delegate: ChecklistActionSheetDelegate)
    
    case createChecklist(
            onNewChecklist: EmptyCompletion,
            onNewFromTemplate: EmptyCompletion,
            onCreateTemplate: EmptyCompletion,
            onCreateSchedule: EmptySubject
         )
    case none
    
    var isActionSheedVisible: Bool {
        switch self {
        case .none: return false
        default: return true
        }
    }
    
    var actionSheet: ActionSheet {
        switch self {
        case .editChecklist(let checklist, let delegate):
            return ChecklistActionSheet
                .actionMenu(checklist: checklist, delegate: delegate)
                .view
        case .createChecklist(let onNewChecklist, let onNewFromTemplate, let onCreateTemplate, let onCreateSchedule):
            return ActionSheet(
                title: Text("CREATE NEW"),
                message: nil,
                buttons: [
                    .default(Text("Checklist")) {
                        onNewChecklist()
                    },
                    .default(Text("Checklist from Template")) {
                        onNewFromTemplate()
                    },
                    .default(Text("Template")) {
                        onCreateTemplate()
                    },
                    .default(Text("Schedule")) {
                        onCreateSchedule.send()
                    },
                    .cancel()
                ]
            )
        default: return ActionSheet(title: Text(""))
        }
        
    }
}
