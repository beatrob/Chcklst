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

enum MyTemplatesActionSheet {
    case templateActions(
        template: TemplateDataModel,
        onCreateChecklist: EmptyCompletion,
        onCreateSchedule: EmptyCompletion,
        onEdit: EmptyCompletion,
        onDelete: EmptyCompletion
    )
    case none
    
    var isActionSheetVisible: Bool {
        switch self {
        case .none: return false
        default: return true
        }
    }
    
    var title: String {
        switch self {
        case .templateActions(
            let template,
            let onCreateChecklist,
            let onCreateSchedule,
            let onEdit,
            let onDelete
            ):
            return template.title
        case .none:
            return ""
        }
    }

    @ViewBuilder
    func buttons(
        onSelection: @escaping (@escaping EmptyCompletion) -> Void = { action in action() }
    ) -> some View {
        switch self {
        case .templateActions(_, let onCreateChecklist, let onCreateSchedule, let onEdit, let onDelete):
            Button("Create checklist") { onSelection(onCreateChecklist) }
            Button("Create schedule") { onSelection(onCreateSchedule) }
            Button("Edit") { onSelection(onEdit) }
            Button("Delete", role: .destructive) { onSelection(onDelete) }
        case .none:
            EmptyView()
        }
    }
}
