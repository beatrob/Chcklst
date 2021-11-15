//
//  DebugNotificationsViewModel.swift
//  checklist
//
//  Created by Robert Konczi on 11/14/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


class DebugNotificationsViewModel: ObservableObject {
    
    static let id = "?###debugnotifications"
    @Published var cells: [DebugCellViewModel] = []
    let navbar = BackButtonNavBarViewModel(title: "Pending Notifications")
    
    init(notificationManager: NotificationManager) {
        notificationManager.getPendingNotifications().done { notifications in
            self.cells = notifications.map { DebugCellViewModel(notification: $0) }
        }
    }
}
