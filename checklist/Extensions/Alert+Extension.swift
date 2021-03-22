//
//  Alert+Extension.swift
//  checklist
//
//  Created by Róbert Konczi on 11.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI


extension Alert {
    
    static var empty: Alert {
        Alert(title: Text(""))
    }
    
    static func getConfirmDeleteChecklist(onDelete: @escaping EmptyCompletion) -> Alert {
        Alert(
            title: Text("Delete"),
            message: Text("Do you really want to delete this checklist?"),
            primaryButton: .destructive(Text("Delete"), action: onDelete),
            secondaryButton: .cancel(Text("Cancel"))
        )
    }
    
    static func getWrongReminderDate() -> Alert {
        Alert(title: Text("Please select a date in the future"))
    }
    
    static func getEnablePushNotifications() -> Alert {
        Alert(
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
    }
    
    static func getTemplateCreated(onGoToTemplates: @escaping EmptyCompletion) -> Alert {
        Alert(
            title: Text("Template created"),
            message: Text("Do you want to see your templates?"),
            primaryButton: .default(Text("Yes"), action: onGoToTemplates),
            secondaryButton: .cancel(Text("No"))
        )
    }
}
