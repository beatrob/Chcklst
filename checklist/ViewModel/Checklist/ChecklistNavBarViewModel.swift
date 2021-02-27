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
    
    private var cancellables = Set<AnyCancellable>()
}


