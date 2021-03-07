//
//  ChecklistAlert.swift
//  checklist
//
//  Created by Róbert Konczi on 11.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI


enum ChecklistAlert {
    
    case notificationsDisabled
    case none
    
    var view: Alert {
        switch self {
        case .notificationsDisabled:
            return Alert(
                title: Text("Please enable push notification in the Settings app."),
                primaryButton: .default(
                    Text("Go to Settings"),
                    action: {
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        UIApplication.shared.open(settingsUrl)
                    }
                ),
                secondaryButton: .cancel()
            )
        case .none:
            return .empty
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
