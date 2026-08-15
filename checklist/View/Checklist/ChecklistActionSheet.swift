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
    
    var title: String {
        switch self {
        case .none: return ""
        case .actionMenu(let checklist, _): return checklist.title
        }
    }

    @ViewBuilder
    func buttons(onSelection: @escaping () -> Void = {}) -> some View {
        switch self {
        case .none:
            EmptyView()
        case .actionMenu(let checklist, let delegate):
            Button("Edit") { onSelection(); delegate.onEditAction(checklist: checklist) }
            Button("Edit reminder") { onSelection(); delegate.onSetReminderAction(checklist: checklist) }
            Button(checklist.isDone ? "Mark all undone" : "Mark all done") {
                onSelection()
                if checklist.isDone {
                    delegate.onMarkAllUndoneAction(checklist: checklist)
                } else {
                    delegate.onMarkAllDoneAction(checklist: checklist)
                }
            }
            Button("Create Template") { onSelection(); delegate.onSaveAsTemplateAction(checklist: checklist) }
            Button("Delete", role: .destructive) { onSelection(); delegate.onDeleteAction(checklist: checklist) }
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
