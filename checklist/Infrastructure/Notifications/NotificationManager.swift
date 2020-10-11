//
//  NotificationManager.swift
//  checklist
//
//  Created by Róbert Konczi on 19/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import UserNotifications
import PromiseKit
import Combine


enum NotificationError: LocalizedError {
    case nilReminderDate
    
    var errorDescription: String? {
        switch self {
        case .nilReminderDate:
            return "Reminder date can not be nil"
        }
    }
}


class NotificationManager: NSObject {
    
    private let _deeplinkChecklistId: CurrentValueSubject<String?, Never> = .init(nil)
    var deeplinkChecklistId: AnyPublisher<String?, Never> {
        _deeplinkChecklistId.eraseToAnyPublisher()
    }
    
    func registerPushNotifications() -> Promise<Bool> {
        Promise { resolver in
            UNUserNotificationCenter
                .current()
                .requestAuthorization(options: [.alert, .announcement, .badge, .sound]) { granted, error in
                    if let error = error {
                        resolver.reject(error)
                    } else {
                        resolver.fulfill(granted)
                    }
            }
        }
    }
    
    func setupReminder(for checklist: ChecklistDataModel) -> Promise<Void> {
        Promise { resolver in
            guard let reminderDate = checklist.reminderDate else {
                resolver.reject(NotificationError.nilReminderDate)
                return
            }
            let content = UNMutableNotificationContent()
            content.title = checklist.title
            content.body = "It's time to get things done. Your checklist is waiting for you!"
            content.sound = .default
            
            let dateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: reminderDate
            )
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: checklist.id,
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    resolver.reject(error)
                }
                resolver.fulfill(())
            }
        }
    }
    
    func clearDeeplinkcChecklistId() {
        log(debug: "Clearing deeplink checklist ID")
        _deeplinkChecklistId.send(nil)
    }
}


extension NotificationManager: UNUserNotificationCenterDelegate {
   
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        log(debug: "Did receive notification with identifier: \(response.notification.request.identifier)")
        _deeplinkChecklistId.send(
            response.notification.request.identifier
        )
    }
}
