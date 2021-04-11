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
        case .createFromTemplate, .createNew:
            return .init("Create")
        case .update, .updateTemplate:
            return .init("Save")
        case .createTemplate:
            return .init("Create template")
        case .display:
            return .init("")
        }
    }
}
