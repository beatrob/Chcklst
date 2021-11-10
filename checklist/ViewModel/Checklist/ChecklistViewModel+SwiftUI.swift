//
//  ChecklistViewModel+NavigationBar.swift
//  checklist
//
//  Created by Róbert Konczi on 24/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI


extension ChecklistViewModel {
    
    var actionButtonTitle: LocalizedStringKey {
        switch viewState {
        case .createChecklistFromTemplate, .createChecklist:
            return .init("Create")
        case .updateChecklist, .updateTemplate:
            return .init("Save")
        case .createTemplateFromChecklist, .createTemplate:
            return .init("Create Template")
        case .display:
            return .init("")
        }
    }
}
