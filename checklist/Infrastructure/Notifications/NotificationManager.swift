//
//  NotificationManager.swift
//  checklist
//
//  Created by Róbert Konczi on 19/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import UserNotifications


class NotificationManager {
    
    func registerPushNotifications(_ completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .announcement, .badge, .sound]) { granted, error in
                DispatchQueue.main.async {
                    completion(granted)
                }
        }
    }
}
