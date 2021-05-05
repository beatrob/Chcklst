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
    let  closeSearchButtonViewModel = NavBarChipButtonViewModel(title: nil, icon: Image(systemName: "xmark"))
    @Published var sortedByTitle: String = SortDataModel.initial.title
    @Published var filterTitle: String = FilterDataModel.initial.title
    @Published var isFilterVisible: Bool = FilterDataModel.initial.isVisibleInNavbar
    @Published var isSearchBarVisible: Bool = false
    @Published var searchText: String = ""
    @Published var isSearchTitleVisible = true
    
    let onMenuTapped = EmptySubject()
    let onAddTapped = EmptySubject()
    var search: AnyPublisher<String?, Never> {
        $searchText
            .map { text -> String? in
                guard text.count > 2 else {
                    return nil
                }
                return text
            }
            .eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    
    init() {
        menuButtonViewModel.didTap.subscribe(onMenuTapped).store(in: &cancellables)
        addButtonViewModel.didTap.subscribe(onAddTapped).store(in: &cancellables)
        searchButtonViewModel.didTap.sink { [weak self] in
            withAnimation {
                self?.isSearchBarVisible = true
            }
        }.store(in: &cancellables)
        closeSearchButtonViewModel.didTap.sink { [weak self] in
            self?.searchText = ""
            self?.isSearchTitleVisible = true
            withAnimation {
                self?.isSearchBarVisible = false
            }
        }.store(in: &cancellables)
    }
}
