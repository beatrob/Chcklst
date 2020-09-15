//
//  DashboardAlert.swift
//  checklist
//
//  Created by Róbert Konczi on 23/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

enum DashboardAlert {
    
    case none
    case templateCreated(gotoTemplates: EmptyCompletion)
    
    var view: Alert {
        switch self {
        case .templateCreated(let gotoTemplates):
            return Alert(
                title: Text("Template created"),
                message: Text("Do you want to see your templates?"),
                primaryButton: .default(Text("Yes"), action: gotoTemplates),
                secondaryButton: .cancel(Text("No"))
            )
        case .none: return Alert(title: Text(""))
        }
    }
    
    var isVisible: Bool {
        switch self {
        case .none: return false
        default: return true
        }
    }
    
}
