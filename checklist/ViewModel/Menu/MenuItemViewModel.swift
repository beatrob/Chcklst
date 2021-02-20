//
//  MenuItemViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 15.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine


class MenuItemViewModel<DataModel: Identifiable>: ObservableObject, Identifiable {
    
    @Published var title: String
    
    private var data: DataModel
    
    var cancellables = Set<AnyCancellable>()
    
    let onSelect = EmptySubject()
    let onSelectMenuItem = PassthroughSubject<DataModel, Never>()
    
    init(dataModel: DataModel) {
        self.data = dataModel
        self.title = String(describing: dataModel.id)
        onSelect.sink { [weak self] in
            guard let self = self else { return }
            self.onSelectMenuItem.send(self.data)
        }.store(in: &cancellables)
    }
}
