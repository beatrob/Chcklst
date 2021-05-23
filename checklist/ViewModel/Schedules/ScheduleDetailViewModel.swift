//
//  ScheduleDetailViewModel.swift
//  checklist
//
//  Created by Robert Konczi on 5/20/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Combine
import SwiftUI

class ScheduleDetailViewModel: ObservableObject {
    
    let backButtonViewModel = NavBarChipButtonViewModel.getBackButton()
    let repeatCheckboxViewModel: CheckboxViewModel
    @Published var title: String
    @Published var description: String
    @Published var items: [ChecklistItemViewModel]
    @Published var isRepeatOn: Bool = false {
        didSet {
            repeatFrequencyCheckboxes.forEach { $0.isChecked = false }
            customDaysCheckboxes.forEach { $0.isChecked = false }
        }
    }
    @Published var shouldDisplayDays: Bool = false {
        didSet {
            customDaysCheckboxes.forEach { $0.isChecked = false }
        }
    }
    @Published var date = Date()
    let repeatFrequencyCheckboxes: [CheckboxViewModel]
    let customDaysCheckboxes: [CheckboxViewModel]
    var cancellables = Set<AnyCancellable>()
    var freqCancellables = Set<AnyCancellable>()
    
    init(state: ScheduleDetailViewState) {
        self.title = state.title
        self.description = state.description ?? ""
        self.items = state.items
        self.repeatCheckboxViewModel = CheckboxViewModel(
            title: "Repeat",
            isChecked: state.isRepeatOn
        )
        repeatFrequencyCheckboxes = ScheduleDataModel.RepeatFrequency.allCases
            .map { freq -> CheckboxViewModel? in
                guard let name = freq.name else {
                    return nil
                }
                return CheckboxViewModel(
                    title: name,
                    isChecked: false,
                    data: freq
                )
            }.compactMap { $0 }
        customDaysCheckboxes = DayDataModel.allCases.map {
            CheckboxViewModel(title: $0.title, isChecked: false)
        }
        repeatFrequencyCheckboxes.forEach { vM in
            vM.checked.dropFirst().sink { [weak self] checked in
                guard
                    let self = self,
                    let freq = vM.data as? ScheduleDataModel.RepeatFrequency
                else {
                    return
                }
                if checked {
                    self.repeatFrequencyCheckboxes
                        .filter { vM != $0 }
                        .forEach { $0.isChecked = false }
                }
                self.shouldDisplayDays = checked && freq.isCustomDays
            }.store(in: &cancellables)
        }
        self.repeatCheckboxViewModel.checked.sink { [weak self] isChecked in
            withAnimation {
                self?.isRepeatOn = isChecked
            }
        }.store(in: &cancellables)
    }
}

