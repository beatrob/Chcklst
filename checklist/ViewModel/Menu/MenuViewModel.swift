//
//  MenuViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 15.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine

struct MenuItemDataModel: Identifiable {
    
    var id: String { title }
    let title: String
}

class MenuViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    @Published var sortItems: [MenuItemViewModel<SortDataModel>]
    @Published var filterItems: [MenuItemViewModel<FilterDataModel>]
    @Published var schedules = MenuItemViewModel<MenuItemDataModel>(
        dataModel: .init(title: "Schedules"), isSelected: false
    )
    @Published var myTemplates = MenuItemViewModel<MenuItemDataModel>(
        dataModel: .init(title: "Templates"), isSelected: false
    )
    @Published var settings = MenuItemViewModel<MenuItemDataModel>(
        dataModel: .init(title: "Settings"), isSelected: false
    )
    @Published var about = MenuItemViewModel<MenuItemDataModel>(
        dataModel: .init(title: "About"), isSelected: false
    )
    @Published var selectedSort: SortDataModel = .initial {
        didSet {
            sortItems.forEach { item in
                item.isSelected = item.data == selectedSort
            }
        }
    }
    @Published var selectedFilter: FilterDataModel = .initial {
        didSet {
            filterItems.forEach { item in
                item.isSelected = item.data == selectedFilter
            }
        }
    }
    
    let onSelectSort = PassthroughSubject<SortDataModel, Never>()
    let onSelectFilter = PassthroughSubject<FilterDataModel, Never>()
    let onSelectSchedules = EmptySubject()
    let onSelectMyTemplates = EmptySubject()
    let onSelectSettings = EmptySubject()
    let onSelectAbout = EmptySubject()
    
    init() {
        sortItems = SortDataModel.allCases.map {
            MenuItemViewModel(dataModel: $0, isSelected: $0 == .initial )
        }
        filterItems = FilterDataModel.allCases.map {
            MenuItemViewModel(dataModel: $0, isSelected: $0 == .initial)
        }
        sortItems.forEach { viewModel in
            viewModel.onSelectMenuItem.sink { [weak self] item in
                self?.selectedSort = item
                self?.onSelectSort.send(item)
            }.store(in: &cancellables)
        }
        filterItems.forEach { viewModel in
            viewModel.onSelectMenuItem.sink { [weak self] item in
                self?.selectedFilter = item
                self?.onSelectFilter.send(item)
            }.store(in: &cancellables)
        }
        schedules.onSelect.subscribe(onSelectSchedules).store(in: &cancellables)
        myTemplates.onSelect.subscribe(onSelectMyTemplates).store(in: &cancellables)
        settings.onSelect.subscribe(onSelectSettings).store(in: &cancellables)
        about.onSelect.subscribe(onSelectAbout).store(in: &cancellables)
    }
}
