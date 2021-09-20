//
//  ScheduleDetailViewModel.swift
//  checklist
//
//  Created by Robert Konczi on 5/20/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Combine
import SwiftUI
import PromiseKit

class ScheduleDetailViewModel: ObservableObject {
    
    @Published var viewTitle: String
    @Published var title: String
    @Published var description: String
    @Published var items: [ChecklistItemViewModel]
    @Published var isRepeatOn: Bool = false {
        didSet {
            if !isRepeatOn {
                repeatFrequencyCheckboxes.forEach { $0.isChecked = false }
                customDaysCheckboxes.forEach { $0.isChecked = false }
            }
        }
    }
    @Published var shouldDisplayDays: Bool = false {
        didSet {
            customDaysCheckboxes.forEach { $0.isChecked = false }
        }
    }
    @Published var date: Date
    @Published var isAlertPresented = false
    @Published var alert: Alert = .empty
    
    private let referenceDate = Date()
    private let state: ScheduleDetailViewState
    private var repeatFrequency: ScheduleDataModel.RepeatFrequency? {
        didSet {
            objectWillChange.send()
        }
    }
    private let didCreateSheduleSubject = EmptySubject()
    private let didUpdateSheduleSubject = EmptySubject()
    private let didDeleteSheduleSubject = EmptySubject()
    private let scheduleDataSource: ScheduleDataSource
    private let notificationManager: NotificationManager
    let backButtonViewModel = NavBarChipButtonViewModel.getBackButton()
    let repeatCheckboxViewModel: CheckboxViewModel
    var isActionButtonDisabled: Bool {
        title.isEmpty || date == referenceDate || (isRepeatOn && !(repeatFrequency?.isValid ?? false))
    }
    let repeatFrequencyCheckboxes: [CheckboxViewModel]
    let customDaysCheckboxes: [CheckboxViewModel]
    let actionButtonTitle: String
    let onActionButtonTapped = EmptySubject()
    let navbarViewModel = BackButtonNavBarViewModel(
        title: "Edit Schedule",
        rightButton: .init(title: nil, icon: .init(systemName: "trash"))
    )
    
    var cancellables = Set<AnyCancellable>()
    var didCreateSchedule: EmptyPublisher {
        didCreateSheduleSubject.eraseToAnyPublisher()
    }
    var didUpdateSchedule: EmptyPublisher {
        didUpdateSheduleSubject.eraseToAnyPublisher()
    }
    var didDeleteSchedule: EmptyPublisher {
        didDeleteSheduleSubject.eraseToAnyPublisher()
    }
    var isNavbarVisible: Bool { state.isUpdate }
    
    init(
        state: ScheduleDetailViewState,
        scheduleDataSource: ScheduleDataSource,
        notificationManager: NotificationManager
    ) {
        self.scheduleDataSource = scheduleDataSource
        self.notificationManager = notificationManager
        self.state = state
        self.title = state.title
        self.description = state.description ?? ""
        self.items = state.items
        self.repeatCheckboxViewModel = CheckboxViewModel(
            title: "Repeat",
            isChecked: state.isRepeatOn
        )
        self.actionButtonTitle = state.actionButtonTitle
        if let schedule = state.schedule {
            self.date = schedule.scheduleDate
            self.repeatFrequency = schedule.repeatFrequency
            self.isRepeatOn = !schedule.repeatFrequency.isNever
        } else {
            self.date = referenceDate
        }
        
        viewTitle = state.isCreate ? "Create Schedule" : ""
        
        self.navbarViewModel.backButton.didTap
            .subscribe(backButtonViewModel.didTapSubject)
            .store(in: &cancellables)
        
        repeatFrequencyCheckboxes = ScheduleDataModel.RepeatFrequency.allCases
            .map { freq -> CheckboxViewModel? in
                guard let name = freq.name else {
                    return nil
                }
                return CheckboxViewModel(
                    title: name,
                    isChecked: state.schedule?.repeatFrequency ?? .never == freq,
                    data: freq
                )
            }.compactMap { $0 }
        customDaysCheckboxes = DayDataModel.allCases.map {
            let isChecked = state.schedule?.repeatFrequency.getCustomDaysIfAvailable.contains($0) ?? false
            return CheckboxViewModel(
                title: $0.title,
                isChecked: isChecked
            )
        }
        
        observeRepeatFreqCheckobxes()
        observeCustomDaysCheckboxes()
        
        self.repeatCheckboxViewModel.checked.sink { [weak self] isChecked in
            if !isChecked {
                self?.repeatFrequency = nil
            }
            withAnimation {
                self?.isRepeatOn = isChecked
            }
        }.store(in: &cancellables)
        
        self.onActionButtonTapped.sink { [weak self] _ in
            guard let self = self, self.checkMandatoryFormData() else {
                return
            }
            notificationManager.registerPushNotifications().done { success in
                if success {
                    let freq = self.repeatFrequency ?? .never
                    if state.isCreate, let template = state.template {
                        self.createSchedule(from: template, repeatFreq: freq)
                    } else if state.isUpdate, let schedule = state.schedule {
                        self.updateSchedule(schedule, repeatFreq: freq)
                    }
                } else {
                    self.alert = .getEnablePushNotifications()
                    self.isAlertPresented = true
                }
            }
        }.store(in: &cancellables)
        
        self.navbarViewModel.rightButton?.didTap.sink { [weak self] in
            guard let self = self, let schedule = state.schedule else {
                return
            }
            let alert = Alert(
                title: Text("Do you really want to delete this schedule?"),
                message: nil,
                primaryButton: .destructive(Text("Delete"), action: {
                    scheduleDataSource.deleteSchedule(schedule).done {
                        self.didDeleteSheduleSubject.send()
                    }.catch {
                        $0.log(message: "Failed to delete schedule")
                    }
                }),
                secondaryButton: .cancel()
            )
            self.alert = alert
            self.isAlertPresented = true
        }.store(in: &cancellables)
    }
}


private extension ScheduleDetailViewModel {
    
    /// - Returns: `true` if everything OK
    func checkMandatoryFormData() -> Bool {
        guard !title.isEmpty else {
            presentWrongFormData(with: "Please name your scheduled checklist")
            return false
        }
        guard date > Date() else {
            presentWrongFormData(with: "Please chose an upcoming schedule date")
            return false
        }
        if isRepeatOn && repeatFrequency == nil {
            presentWrongFormData(with: "Please select a valid repeat frequency")
            return false
        }
        return true
    }
    
    func observeRepeatFreqCheckobxes() {
        repeatFrequencyCheckboxes.forEach { vM in
            vM.checked.dropFirst().sink { [weak self] checked in
                guard
                    let self = self,
                    let freq = vM.data as? ScheduleDataModel.RepeatFrequency
                else {
                    return
                }
                if checked {
                    self.repeatFrequency = freq
                    self.repeatFrequencyCheckboxes
                        .filter { vM != $0 }
                        .forEach { $0.isChecked = false }
                } else {
                    if let repeatFreq = self.repeatFrequency, repeatFreq == freq {
                        self.repeatFrequency = nil
                    }
                }
                self.shouldDisplayDays = checked && freq.isCustomDays
            }.store(in: &cancellables)
        }
    }
    
    func observeCustomDaysCheckboxes() {
        customDaysCheckboxes.forEach { vM in
            vM.checked.dropFirst().sink { [weak self] checked in
                guard
                    let self = self,
                    self.repeatFrequency?.isCustomDays ?? false
                else {
                    return
                }
                let customDays = self.customDaysCheckboxes
                    .filter { $0.isChecked }
                    .map { $0.data as? DayDataModel}
                    .compactMap { $0 }
                self.repeatFrequency = .customDays(days: customDays)
            }.store(in: &cancellables)
        }
    }
    
    func createSchedule(from template: TemplateDataModel, repeatFreq: ScheduleDataModel.RepeatFrequency) {
        firstly {
            scheduleDataSource.createSchedule(
                .init(
                    id: UUID().uuidString,
                    title: self.title,
                    description: self.description,
                    template: template,
                    scheduleDate: self.date,
                    repeatFrequency: repeatFreq
                )
            )
        }.then { schedule in
            self.notificationManager.setupScheduleNotification(for: schedule)
        }.get { _ in
            self.didCreateSheduleSubject.send()
        }.catch {
            $0.log(message: "Failed to create schedule")
        }
    }
    
    func updateSchedule(_ schedule: ScheduleDataModel, repeatFreq: ScheduleDataModel.RepeatFrequency) {
        scheduleDataSource.updateSchedule(
            .init(
                id: schedule.id,
                title: self.title,
                description: self.description,
                template: schedule.template,
                scheduleDate: self.date,
                repeatFrequency: repeatFreq
            )
        ).done {
            self.didUpdateSheduleSubject.send()
        }.catch {
            $0.log(message: "Failed to update schedule")
        }
    }
    
    func presentWrongFormData(with title: String) {
        self.alert = Alert(title: Text(title), message: nil, dismissButton: .cancel())
        self.isAlertPresented = true
    }
}
