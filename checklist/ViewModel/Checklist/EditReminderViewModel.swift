//
//  EditReminderViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 11.03.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import PromiseKit


class EditReminderViewModel: ObservableObject {
    
    @Published var title: String
    @Published var isReminderOn = false {
        didSet {
            guard isReminderOn else {
                return
            }
            self.notificationManager.registerPushNotifications()
                .done { granted  in
                    if !granted {
                        self.isReminderOn = false
                        self.alert = .getEnablePushNotifications()
                        self.isAlertVisible = true
                    }
                }
                .catch { log(error: $0.localizedDescription) }
        }
    }
    @Published var reminderDate = Date()
    var alert = Alert.empty
    @Published var isAlertVisible: Bool = false
    let onDidDeleteReminder = EmptySubject()
    let onDidCreateReminder = PassthroughSubject<Date, Never>()
    let onSave = EmptySubject()
    private var cancellables = Set<AnyCancellable>()
    private let notificationManager: NotificationManager
    let reminderCheckboxViewModel: CheckboxViewModel
    private let checklistDataSource: ChecklistDataSource
    private let checklist: ChecklistDataModel
    
    init(
        checklist: ChecklistDataModel,
        notificationManager: NotificationManager,
        checklistDataSource: ChecklistDataSource
    ) {
        self.checklistDataSource = checklistDataSource
        self.checklist = checklist
        self.title = checklist.title
        self.notificationManager = notificationManager
        self.isReminderOn = checklist.isValidReminderSet
        if checklist.isValidReminderSet, let date = checklist.reminderDate {
            reminderDate = date
        }
        reminderCheckboxViewModel = CheckboxViewModel(
            title: "Remind me on this device",
            isChecked: checklist.isValidReminderSet
        )
        reminderCheckboxViewModel.checked.sink { [weak self] isChecked in
            withAnimation {
                self?.isReminderOn = isChecked
            }
        }.store(in: &cancellables)
        onSave.sink { [weak self] in
            guard let self = self else { return }
            if !self.isReminderOn {
                self.deleteReminder()
            } else {
                if self.reminderDate >= Date() {
                    self.createReminder(date: self.reminderDate)
                } else {
                    self.alert = .getWrongReminderDate()
                    self.isAlertVisible = true
                }
            }
        }.store(in: &cancellables)
    }
}


private extension EditReminderViewModel {
    
    func createReminder(date: Date) {
        firstly {
            self.checklistDataSource.updateReminderDate(date, for: checklist)
        }.get {
            self.onDidCreateReminder.send(date)
        }.then {
            return self.notificationManager.setupReminder(date: date, for: self.checklist)
        }.catch { error in
            error.log(message: "Failed to save reminder")
            #warning("TODO: Add error hanling")
        }
    }
    
    func deleteReminder() {
        checklistDataSource.updateReminderDate(nil, for: checklist).done {
            self.notificationManager.removeReminder(for: self.checklist)
            self.onDidDeleteReminder.send()
        }.catch { error in
            error.log(message: "Failed to delete reminder")
            #warning("TODO: Add error hanling")
        }
    }
}

