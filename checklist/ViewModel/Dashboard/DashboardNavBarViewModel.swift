//
//  DashboardNavBarViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 18.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


class DashboardNavBarViewModel: ObservableObject {
    
    @Published var menuButtonViewModel = DashboardChipButtonViewModel(
        title: nil,
        icon: Image(systemName: "line.horizontal.3")
    )
    @Published var addButtonViewModel = DashboardChipButtonViewModel(title: nil, icon: Image(systemName: "plus"))
    @Published var searchButtonViewModel = DashboardChipButtonViewModel(
        title: nil,
        icon: Image(systemName: "magnifyingglass")
    )
    @Published var sortedByTitle: String = FilterItemData.initial.title
    
    private var cancellables = Set<AnyCancellable>()
}
