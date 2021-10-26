//
//  ChecklistActionSheet.swift
//  checklist
//
//  Created by Róbert Konczi on 07.03.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

protocol ChecklistActionSheetDelegate {
    func onEditAction(checklist: ChecklistDataModel)
    func onMarkAllDoneAction(checklist: ChecklistDataModel)
    func onMarkAllUndoneAction(checklist: ChecklistDataModel)
    func onSetReminderAction(checklist: ChecklistDataModel)
    func onSaveAsTemplateAction(checklist: ChecklistDataModel)
    func onDeleteAction(checklist: ChecklistDataModel)
}

enum ChecklistActionSheet {
    
    case none
    case actionMenu(checklist: ChecklistDataModel, delegate: ChecklistActionSheetDelegate)
    
    var view: ActionSheet {
        switch self {
        case .none:
            return ActionSheet(title: Text(""))
        case .actionMenu(let checklist, let delegate):
            return ActionSheet(
                title: Text(checklist.title),
                message: nil,
                buttons: [
                    .default(Text("Edit")) {
                        delegate.onEditAction(checklist: checklist)
                    },
                    .default(Text("Edit reminder")) {
                        delegate.onSetReminderAction(checklist: checklist)
                    },
                    checklist.isDone ?
                        .default(Text("Mark all undone")) { delegate.onMarkAllUndoneAction(checklist: checklist) }
                    : .default(Text("Mark all done")) { delegate.onMarkAllDoneAction(checklist: checklist) },
                    .default(Text("Create Template")) {
                        delegate.onSaveAsTemplateAction(checklist: checklist)
                    },
                    .destructive(Text("Delete")) {
                        delegate.onDeleteAction(checklist: checklist)
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
