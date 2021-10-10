//
//  LimitReachedAlert.swift
//  checklist
//
//  Created by Robert Konczi on 10/3/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI

enum LimitReachedAlert {
    
    enum TapAction {
        case upgrade
        case cancel
    }
    
    static func getAlert(title: LocalizedStringKey, callback: @escaping (TapAction) -> Void) -> Alert {
        Alert(
            title: Text(title),
            message: Text(LocalizedStringKey("upgrade_alert_continue_message")),
            primaryButton: .default(Text(LocalizedStringKey("upgrade_button"))) {
                callback(.upgrade)
            },
            secondaryButton: .cancel {
                callback(.cancel)
            }
        )
    }
}
