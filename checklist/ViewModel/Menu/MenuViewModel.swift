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
    @Published var myTemplates = MenuItemViewModel<MenuItemDataModel>(dataModel: .init(title: "My Temlates"))
    @Published var settings = MenuItemViewModel<MenuItemDataModel>(dataModel: .init(title: "Settings"))
    @Published var about = MenuItemViewModel<MenuItemDataModel>(dataModel: .init(title: "About"))
    
    let onSelectSort = PassthroughSubject<SortDataModel, Never>()
    let onSelectFilter = PassthroughSubject<FilterDataModel, Never>()
    
    init() {
        sortItems = SortDataModel.allCases.map { MenuItemViewModel(dataModel: $0) }
        filterItems = FilterDataModel.allCases.map { MenuItemViewModel(dataModel: $0) }
        sortItems.forEach { viewModel in
            viewModel.onSelectMenuItem.subscribe(onSelectSort).store(in: &cancellables)
        }
        filterItems.forEach { viewModel in
            viewModel.onSelectMenuItem.subscribe(onSelectFilter).store(in: &cancellables)
        }
    }
}
