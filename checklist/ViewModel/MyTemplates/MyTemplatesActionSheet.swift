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
        onDelete: EmptyCompletion
    )
    case none
    
    var isActionSheetVisible: Bool {
        switch self {
        case .none: return false
        default: return true
        }
    }
    
    var actionSheet: ActionSheet {
        switch self {
        case .templateActions(let template, let onCreateChecklist, let onDelete):
            return ActionSheet(
                title: Text(template.title),
                message: nil,
                buttons: [
                    .default(Text("Create checklist")) {
                        onCreateChecklist()
                    },
                    .destructive(Text("Delete")) {
                        withAnimation { onDelete() }
                    },
                    .cancel()
                ]
            )
        default: return ActionSheet(title: Text(""))
        }
        
    }
}
