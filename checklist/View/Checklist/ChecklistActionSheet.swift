//
//  ChecklistActionSheet.swift
//  checklist
//
//  Created by Róbert Konczi on 07.03.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

protocol ChecklistActionSheetDelegate {
    func onEditAction()
    func onMarkAllDoneAction()
    func onSetReminderAction()
    func onSaveAsTemplateAction()
    func onDeleteAction()
}

enum ChecklistActionSheet {
    
    case none
    case actionMenu(delegate: ChecklistActionSheetDelegate)
    
    var view: ActionSheet {
        switch self {
        case .none:
            return ActionSheet(title: Text(""))
        case .actionMenu(let delegate):
            return ActionSheet(
                title: Text("Select na option"),
                message: nil,
                buttons: [
                    .default(Text("Edit")) {
                        delegate.onEditAction()
                    },
                    .default(Text("Edit reminder")) {
                        delegate.onSetReminderAction()
                    },
                    .default(Text("Mark all done")) {
                        delegate.onMarkAllDoneAction()
                    },
                    .default(Text("Create Template")) {
                        delegate.onSaveAsTemplateAction()
                    },
                    .destructive(Text("Delete")) {
                        delegate.onDeleteAction()
                    },
                    .cancel()
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
