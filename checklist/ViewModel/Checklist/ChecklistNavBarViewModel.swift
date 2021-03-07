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
    
    let backButton = NavBarChipButtonViewModel(title: nil, icon: Image(systemName: "arrow.backward"))
    let actionsButton = NavBarChipButtonViewModel(title: nil, icon: Image(systemName: "ellipsis"))
    let doneButton = NavBarChipButtonViewModel(title: "Done", icon: Image(systemName: "checkmark"))
    @Published var isEditVisible = true
    var isReminderDateVisible: Bool {
        reminderDate != nil && isEditVisible
    }
    @Published var reminderDate: String?
    
    private var cancellables = Set<AnyCancellable>()
    var checklist: ChecklistDataModel {
        didSet {
            setup()
        }
    }
    
    init(checklist: ChecklistDataModel) {
        self.checklist = checklist
        setup()
    }
}


private extension ChecklistNavBarViewModel {
    
    func setup() {
        reminderDate = checklist.isValidReminderSet ? checklist.reminderDate?.formatedReminderDate() : nil
    }
}
