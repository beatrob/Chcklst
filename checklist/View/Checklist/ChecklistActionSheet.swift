//
//  ChecklistActionSheet.swift
//  checklist
//
//  Created by Róbert Konczi on 07.03.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI


enum ChecklistActionSheet {
    
    case none
    case actionMenu(onEdit: EmptyCompletion, onDelete: EmptyCompletion, onCancel: EmptyCompletion)
    
    var view: ActionSheet {
        switch self {
        case .none:
            return ActionSheet(title: Text(""))
        case .actionMenu(let onEdit, let onDelete, let onCancel):
            return ActionSheet(
                title: Text("Select na option"),
                message: nil,
                buttons: [
                    .default(Text("Edit"), action: onEdit),
                    .destructive(Text("Delete"), action: onDelete),
                    .cancel(onCancel)
                ]
            )
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
