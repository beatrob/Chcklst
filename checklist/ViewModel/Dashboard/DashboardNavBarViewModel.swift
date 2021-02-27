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
    
    @Published var menuButtonViewModel = NavBarChipButtonViewModel(
        title: nil,
        icon: Image(systemName: "line.horizontal.3")
    )
    @Published var addButtonViewModel = NavBarChipButtonViewModel(title: nil, icon: Image(systemName: "plus"))
    @Published var searchButtonViewModel = NavBarChipButtonViewModel(
        title: nil,
        icon: Image(systemName: "magnifyingglass")
    )
    @Published var sortedByTitle: String = SortDataModel.initial.title
    @Published var filterTitle: String = FilterDataModel.initial.title
    @Published var isFilterVisible: Bool = FilterDataModel.initial.isVisibleInNavbar
    
    let onMenuTapped = EmptySubject()
    let onSearchTapped = EmptySubject()
    let onAddTapped = EmptySubject()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        menuButtonViewModel.didTap.subscribe(onMenuTapped).store(in: &cancellables)
        searchButtonViewModel.didTap.subscribe(onSearchTapped).store(in: &cancellables)
        addButtonViewModel.didTap.subscribe(onAddTapped).store(in: &cancellables)
    }
}
