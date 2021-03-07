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
    case editChecklist(
        checklist: ChecklistDataModel,
        onEdit: EmptyCompletion,
        onCreateTemplate: EmptyCompletion,
        onDelete: EmptyCompletion
    )
    case createChecklist(onNewChecklist: EmptyCompletion, onNewFromTemplate: EmptyCompletion)
    case none
    
    var isActionSheedVisible: Bool {
        switch self {
        case .none: return false
        default: return true
        }
    }
    
    var actionSheet: ActionSheet {
        switch self {
        case .editChecklist(let checklist, let onEdit, let onCreateTemplate, let onDelete):
            return ActionSheet(
                title: Text(checklist.title),
                message: nil,
                buttons: [
                    .default(Text("Mark all as done")) {
                        
                    },
                    .default(Text("Edit")) {
                        withAnimation { onEdit() }
                    },
                    .default(Text("Create template")) {
                        onCreateTemplate()
                    },
                    .destructive(Text("Delete")) {
                        withAnimation { onDelete() }
                    },
                    .cancel()
                ]
            )
        case .createChecklist(let onNewChecklist, let onNewFromTemplate):
            return ActionSheet(
                title: Text("Add checklist"),
                message: nil,
                buttons: [
                    .default(Text("Create new")) {
                        onNewChecklist()
                    },
                    .default(Text("Create from template")) {
                        onNewFromTemplate()
                    },
                    .cancel()
                ]
            )
        default: return ActionSheet(title: Text(""))
        }
        
    }
}
