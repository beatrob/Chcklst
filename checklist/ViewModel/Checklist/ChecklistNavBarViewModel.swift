//
//  ChecklistNavBarViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 27.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI
import Combine


class ChecklistNavBarViewModel: ObservableObject {
    
    let backButton = NavBarChipButtonViewModel.getBackButton()
    let actionsButton = NavBarChipButtonViewModel(title: nil, icon: Image(systemName: "ellipsis"))
    let doneButton = NavBarChipButtonViewModel(title: "Done", icon: Image(systemName: "checkmark"))
    @Published var shouldDisplayDoneButton = false
    var isReminderDateVisible: Bool {
        reminderDate != nil && !shouldDisplayDoneButton
    }
    @Published var reminderDate: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(checklist: AnyPublisher<ChecklistDataModel?, Never>) {
        checklist.sink { [weak self] checklist in
            guard let checklist = checklist else {
                self?.reminderDate = nil
                return
            }
            self?.reminderDate = checklist.isValidReminderSet ? checklist.reminderDate?.formatedReminderDate() : nil
        }.store(in: &cancellables)
    }
}
