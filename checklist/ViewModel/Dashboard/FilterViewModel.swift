//
//  FilterViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 09/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


class FilterViewModel: ObservableObject {
    
    struct ItemVO: Identifiable {
        let id = UUID()
        let image: Image
        let filterItem: FilterItemData
        let onTapped: EmptySubject
        
        init(_ item: FilterItemData, onTapped: EmptySubject) {
            self.filterItem = item
            self.image = item.image
            self.onTapped = onTapped
        }
    }
    
    @Published var items: [ItemVO] = []
    @Published var selectedItem: FilterItemData = .initial {
        didSet {
            onSelectFilter.send(selectedItem)
        }
    }
    
    var cancellables =  Set<AnyCancellable>()
    private let onSelectFilter: FilterPassthroughSubject
    
    init(onSelectFilter: FilterPassthroughSubject) {
        self.onSelectFilter = onSelectFilter
        items = FilterItemData.allCases.map { item in
            let onTapped = EmptySubject()
            onTapped.sink { [weak self] in
                self?.selectedItem = item
            }.store(in: &cancellables)
            
            return ItemVO(item, onTapped: onTapped)
        }
        onSelectFilter.send(selectedItem)
    }
}

extension FilterItemData {
    
    var image: Image {
        Image(systemName: imageName)
    }
}
