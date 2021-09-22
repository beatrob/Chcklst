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
    
    private enum Prefix: String {
        case checklist
        case schedule
    }
    
    private let _deeplinkChecklistId: CurrentValueSubject<String, Never> = .init("")
    private let _deeplickScheduleId: CurrentValueSubject<String, Never> = .init("")
    
    var deeplinkChecklistId: AnyPublisher<String, Never> {
        _deeplinkChecklistId.eraseToAnyPublisher()
    }
    
    var deeplinkScheduleId: AnyPublisher<String, Never> {
        _deeplickScheduleId.eraseToAnyPublisher()
    }
    
    func getNotificationsEnabled() -> Guarantee<Bool> {
        Guarantee { resolver in
            UNUserNotificationCenter
                .current()
                .getNotificationSettings { settings in
                    resolver(
                        settings.authorizationStatus == .authorized
                        || settings.authorizationStatus == .provisional
                    )
                }
        }
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
        firstly { () -> Promise<Date> in
            guard let reminderDate = checklist.reminderDate else {
                throw NotificationError.nilReminderDate
            }
            return .value(reminderDate)
        }.then { reminderDate -> Promise<Void> in
            let content = UNMutableNotificationContent()
            content.title = checklist.title
            content.body = "It's time to get things done. Your checklist is waiting for you!"
            content.sound = .default
            
            return self.registerPushNotification(
                prefix: Prefix.checklist,
                identifier: checklist.id,
                contnet: content,
                trigger: UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents(
                        [.year, .month, .day, .hour, .minute],
                        from: reminderDate
                    ),
                    repeats: false
                )
            )
        }
    }
    
    func removeReminder(for checklist: ChecklistDataModel) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [checklist.id])
    }
    
    func setupScheduleNotification(for schedule: ScheduleDataModel) -> Promise<Void> {
        let content = UNMutableNotificationContent()
        content.title = schedule.title
        content.body = "Your scheduled checklist is waiting for you."
        content.sound = .default
        
        let repeats = !schedule.repeatFrequency.isNever && !schedule.repeatFrequency.isCustomDays
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: getDateComponents(
                for: schedule.scheduleDate,
                repeatFrequency: schedule.repeatFrequency
            ),
            repeats: repeats
        )
        let reg1 = registerPushNotification(
            prefix: Prefix.schedule,
            identifier: schedule.id,
            contnet: content,
            trigger: trigger
        )
        if !schedule.repeatFrequency.isNever {
            switch schedule.repeatFrequency {
            case .customDays(let days):
                return when(
                    fulfilled:
                        getDateComponents(for: schedule.scheduleDate, customDays: days)
                            .enumerated()
                            .map {
                                registerPushNotification(
                                    prefix: Prefix.schedule,
                                    identifier: schedule.id + "_\($0.offset)",
                                    contnet: content,
                                    trigger: UNCalendarNotificationTrigger(
                                        dateMatching: $0.element,
                                        repeats: true
                                    )
                                )
                            }
                        + [reg1]
                    )
            default:
                return reg1
            }
        } else {
            return reg1
        }
    }
    
    func clearDeeplinkcChecklistId() {
        log(debug: "Clearing deeplink checklist ID")
        _deeplinkChecklistId.send("")
        _deeplinkChecklistId.send("")
    }
    
    func getPendingSchedules() -> Guarantee<[String]> {
        Guarantee { resolver in
            UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
                let ids = notifications
                    .map { $0.request.identifier }
                    .filter { $0.hasPrefix(Prefix.schedule.rawValue) }
                    .map { self.getScheduleId(fromNotificationId: $0) }
                    .compactMap { $0 }
                resolver(ids)
            }
        }.get { _ in
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
    }
    
    private func registerPushNotification(
        prefix: Prefix,
        identifier: String,
        contnet: UNNotificationContent,
        trigger: UNCalendarNotificationTrigger
    ) -> Promise<Void> {
        Promise { resolver in
            let request = UNNotificationRequest(
                identifier: prefix.rawValue + identifier,
                content: contnet,
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
    
    private func getDateComponents(
        for date: Date,
        repeatFrequency: ScheduleDataModel.RepeatFrequency
    ) -> DateComponents {
        switch repeatFrequency {
        case .daily:
            return Calendar.current.dateComponents([.day, .hour, .minute], from: date)
        case .monthly:
            return Calendar.current.dateComponents([.month, .day, .hour, .minute], from: date)
        case .weekly:
            return Calendar.current.dateComponents([.weekday, .day, .hour, .minute], from: date)
        case .yearly, .never, .customDays:
            return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        }
    }
    
    private func getDateComponents(
        for date: Date,
        customDays: [DayDataModel]
    ) -> [DateComponents] {
        customDays
            .map { Calendar.current.date(bySetting: .weekday, value: $0.weakdayOffset, of: date) }
            .compactMap { $0 }
            .map { Calendar.current.dateComponents([.weekday, .day, .hour, .minute], from: date) }
    }
    
    private func getScheduleId(fromNotificationId notfId: String) -> String? {
        let id = notfId.replacingOccurrences(of: Prefix.schedule.rawValue, with: "")
        let split = id.split(separator: "_")
        if !split.isEmpty {
           return String(split[0])
        } else {
            return nil
        }
    }
}


extension NotificationManager: UNUserNotificationCenterDelegate {
   
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        log(debug: "Did receive notification with identifier: \(identifier)")
        if identifier.hasPrefix(Prefix.checklist.rawValue) {
            _deeplinkChecklistId.send(
                identifier.replacingOccurrences(of: Prefix.checklist.rawValue, with: "")
            )
        } else if identifier.hasPrefix(Prefix.schedule.rawValue),
                  let scheduleId = getScheduleId(fromNotificationId: identifier) {
            _deeplickScheduleId.send(scheduleId)
        }
    }
}
