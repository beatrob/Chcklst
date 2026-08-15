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
    
    var title: String {
        switch self {
        case .editChecklist(let checklist, let delegate):
            return ChecklistActionSheet.actionMenu(checklist: checklist, delegate: delegate).title
        case .createChecklist:
            return "Create New"
        case .none:
            return ""
        }
    }

    @ViewBuilder
    func buttons(onSelection: @escaping () -> Void = {}) -> some View {
        switch self {
        case .editChecklist(let checklist, let delegate):
            ChecklistActionSheet.actionMenu(checklist: checklist, delegate: delegate).buttons(onSelection: onSelection)
        case .createChecklist(let onNewChecklist, let onNewFromTemplate, let onCreateTemplate, let onCreateSchedule):
            Button("Checklist") { onSelection(); onNewChecklist() }
            Button("Checklist from Template") { onSelection(); onNewFromTemplate() }
            Button("Template") { onSelection(); onCreateTemplate() }
            Button("Schedule") { onSelection(); onCreateSchedule.send() }
        case .none:
            EmptyView()
        }
    }
}
