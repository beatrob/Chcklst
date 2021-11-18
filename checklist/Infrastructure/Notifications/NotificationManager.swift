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
    private let _deeplinkScheduleId: CurrentValueSubject<String, Never> = .init("")
    private let checklistDataSource: ChecklistDataSource
    
    var deeplinkChecklistId: AnyPublisher<String, Never> {
        _deeplinkChecklistId.eraseToAnyPublisher()
    }
    
    var deeplinkScheduleId: AnyPublisher<String, Never> {
        _deeplinkScheduleId.eraseToAnyPublisher()
    }
    
    init(checklistDataSource: ChecklistDataSource) {
        self.checklistDataSource = checklistDataSource
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
                .requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    if let error = error {
                        resolver.reject(error)
                    } else {
                        resolver.fulfill(granted)
                    }
            }
        }
    }
    
    func setupReminder(date: Date, for checklist: ChecklistDataModel) -> Promise<Void> {
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
                    from: date
                ),
                repeats: false
            )
        )
    }
    
    func removeReminder(for checklist: ChecklistDataModel) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [checklist.id])
    }
    
    func removeReminder(for schedule: ScheduleDataModel) -> Guarantee<Void> {
        Guarantee { res in
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                let notifications = requests.filter { $0.identifier.contains(schedule.id) }
                guard !notifications.isEmpty else {
                    res(())
                    return
                }
                UNUserNotificationCenter.current().removePendingNotificationRequests(
                    withIdentifiers: notifications.map { $0.identifier }
                )
                res(())
            }
        }
    }
    
    func setupScheduleNotification(for schedule: ScheduleDataModel) -> Promise<Void> {
        let content = UNMutableNotificationContent()
        content.title = schedule.title
        content.body = "Your scheduled checklist is waiting for you."
        content.sound = .default
        
        let repeats = !schedule.repeatFrequency.isNever && !schedule.repeatFrequency.isCustomDays
        let defaultWeekday = Calendar.current.dateComponents([.weekday], from: schedule.scheduleDate)
        let defaultDateComponents = getDateComponents(
            for: schedule.scheduleDate,
            repeatFrequency: schedule.repeatFrequency
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: defaultDateComponents,
            repeats: repeats
        )
        if !schedule.repeatFrequency.isNever {
            switch schedule.repeatFrequency {
            case .customDays(let days):
                let dateComponents = getDateComponents(for: schedule.scheduleDate, customDays: days)
                let containsDefaultDateComponents = dateComponents.first {
                    $0.weekday == defaultWeekday.weekday && $0.weekday != nil
                } != nil
                return when(
                    fulfilled: dateComponents.enumerated().map {
                                registerPushNotification(
                                    prefix: Prefix.schedule,
                                    identifier: schedule.id + "_\($0.offset)",
                                    contnet: content,
                                    trigger: UNCalendarNotificationTrigger(
                                        dateMatching: $0.element,
                                        repeats: true
                                    )
                                )
                            } + (containsDefaultDateComponents ? [] : [
                                        registerPushNotification(
                                            prefix: Prefix.schedule,
                                            identifier: schedule.id,
                                            contnet: content,
                                            trigger: trigger
                                        )
                                    ]
                                )
                ).then {
                    self.debugPendingNotifications()
                }
            default:
                return registerPushNotification(
                    prefix: Prefix.schedule,
                    identifier: schedule.id,
                    contnet: content,
                    trigger: trigger
                )
            }
        } else {
            return registerPushNotification(
                prefix: Prefix.schedule,
                identifier: schedule.id,
                contnet: content,
                trigger: trigger
            )
        }
        
        
    }
    
    func clearDeeplinkChecklistId() {
        log(debug: "Clearing deeplink checklist ID")
        _deeplinkChecklistId.send("")
        _deeplinkChecklistId.send("")
    }
    
    func getDeliveredReminders() -> Guarantee<DeliveredRemindersDataModel> {
        Guarantee { resolver in
            UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
                let ids = notifications.map { $0.request.identifier }
                let scheduleIds = ids.filter { $0.hasPrefix(Prefix.schedule.rawValue) }
                    .map { self.getScheduleId(fromNotificationId: $0) }
                    .compactMap { $0 }
                let checklistIds = ids.filter { $0.hasPrefix(Prefix.checklist.rawValue) }
                    .map { self.getChecklistId(from: $0) }
                    .compactMap { $0 }
                resolver(.init(scheduleIds: scheduleIds, checklistIds: checklistIds))
            }
        }.get { _ in
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
    }
    
    func getPendingNotifications() -> Guarantee<[NotificationDataModel]> {
        Guarantee { fulfill in
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                fulfill(requests.map {
                    let calendarNT = $0.trigger as? UNCalendarNotificationTrigger
                    let intervalNT = $0.trigger as? UNTimeIntervalNotificationTrigger
                    let isRepeat: Bool? = calendarNT?.repeats ?? intervalNT?.repeats
                    let nextTriggerDate = calendarNT?.nextTriggerDate() ?? intervalNT?.nextTriggerDate()
                    let dateComponents = calendarNT?.dateComponents
                    let interval = intervalNT?.timeInterval
                    return NotificationDataModel(
                        id: $0.identifier,
                        title: $0.content.title,
                        nextTriggerDate: nextTriggerDate,
                        isRepeat: isRepeat ?? false,
                        timeInterval: interval,
                        dateComponents: dateComponents
                    )
                })
                
            }
        }
    }
}


//MARK:- Private methods

private extension NotificationManager {
    
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
    
    func getDateComponents(
        for date: Date,
        repeatFrequency: ScheduleDataModel.RepeatFrequency
    ) -> DateComponents {
        switch repeatFrequency {
        case .daily:
            return Calendar.current.dateComponents([.hour, .minute], from: date)
        case .monthly:
            return Calendar.current.dateComponents([.hour, .minute, .day], from: date)
        case .weekly, .customDays:
            return Calendar.current.dateComponents([.weekday, .hour, .minute], from: date)
        case .yearly, .never:
            return Calendar.current.dateComponents([.hour, .minute, .day, .month], from: date)
        }
    }
    
    func getDateComponents(
        for date: Date,
        customDays: [DayDataModel]
    ) -> [DateComponents] {
        let originalHourAndMinute = Calendar.current.dateComponents([.hour, .minute], from: date)
        guard
            let originalHour = originalHourAndMinute.hour,
            let originalMinute = originalHourAndMinute.minute
        else {
            return []
        }
        
        let days = customDays
            .compactMap { day -> DateComponents? in
                
                guard
                    let weekDayDate = Calendar.current.date(
                        bySetting: .weekday,
                        value: day.calendarWeekdayOffset,
                        of: date
                    ),
                    let newDate = Calendar.current.date(
                        bySettingHour: originalHour,
                        minute: originalMinute,
                        second: 0,
                        of: weekDayDate
                    )
                else {
                    return nil
                }
                
                return Calendar.current.dateComponents([.weekday, .hour, .minute], from: newDate)
            }
        return days
    }
    
    func getScheduleId(fromNotificationId notfId: String) -> String? {
        let id = notfId.replacingOccurrences(of: Prefix.schedule.rawValue, with: "")
        let split = id.split(separator: "_")
        if !split.isEmpty {
           return String(split[0])
        } else {
            return nil
        }
    }
    
    func getChecklistId(from notificationId: String) -> String? {
        guard notificationId.hasPrefix(Prefix.checklist.rawValue) else {
            return nil
        }
        return notificationId.replacingOccurrences(
            of: Prefix.checklist.rawValue,
            with: ""
        )
    }
    
    func debugPendingNotifications() -> Promise<Void> {
        #if DEBUG
        return Promise { res in
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                log(
                    debug: "Pending notification requests:\n\(requests.map { String(describing: $0) }.joined(separator: "\n"))"
                )
                res.fulfill(())
            }
        }
        #else
        return .value
        #endif
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
            _deeplinkScheduleId.send(scheduleId)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let identifier = notification.request.identifier
        if identifier.hasPrefix(Prefix.schedule.rawValue),
            let scheduleId = getScheduleId(fromNotificationId: identifier) {
            _deeplinkScheduleId.send(scheduleId)
            return .banner
        } else if let id = getChecklistId(from: identifier) {
            return await withCheckedContinuation { continuation in
                checklistDataSource.deleteExpiredNotification(for: id).done {
                    log(debug: "Checklist with id \(id) deleted")
                }.ensure {
                    continuation.resume(returning: .banner)
                }.catch { error in
                    error.log(message: "Failed to remove reminder")
                }
            }
        }
        return .banner
    }
}
