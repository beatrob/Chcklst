//
//  MyTemplatesAlert.swift
//  checklist
//
//  Created by Róbert Konczi on 07/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


enum MyTemplatesAlert {
    
    case createChecklistSucess(onGotoDashboard: EmptyCompletion)
    case none
    
    var alert: Alert {
        switch self {
        case .createChecklistSucess(let onGotoDashboard):
            return Alert(
                title: Text("New checklist created"),
                primaryButton: .default(Text("Go to Dashboard"), action: onGotoDashboard),
                secondaryButton: .cancel()
            )
        case .none:
            return Alert(title: Text(""))
        }
    }
    
    var isVisible: Bool {
        switch self {
        case .none: return false
        default: return true
        }
    }
    
}
