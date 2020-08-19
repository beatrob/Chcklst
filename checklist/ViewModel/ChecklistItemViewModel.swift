//
//  ChecklistItemViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 16/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


class ChecklistItemViewModel: ObservableObject {
    
    @Published var name: String = ""
    @Published var isDone: Bool = false
    let onSwipeRight: PassthroughSubject<Void, Never> = .init()
    let onSwipeLeft: PassthroughSubject<Void, Never> = .init()
    let onCheckMarkTapped: PassthroughSubject<Void, Never> = .init()
    
    var cancellables =  Set<AnyCancellable>()
    
    init(item: CurrentValueSubject<ChecklistItemDataModel, Never>) {
        
        item.sink {
            self.name = $0.name
            self.isDone = $0.isDone
        }.store(in: &cancellables)
        
        onSwipeRight.sink {
            item.value.toDone()
        }.store(in: &cancellables)
        
        onSwipeLeft.sink {
            item.value.toUnDone()
        }.store(in: &cancellables)
        
        onCheckMarkTapped.sink {
            item.value.toggleDone()
        }.store(in: &cancellables)
    }
}
