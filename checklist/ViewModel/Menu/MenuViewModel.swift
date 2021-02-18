//
//  MenuViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 15.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine


class MenuViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    @Published var filterItems: [MenuItemViewModel<FilterItemData>]
    
    
    init() {
        filterItems = FilterItemData.allCases.map { MenuItemViewModel(dataModel: $0) }
    }
}
