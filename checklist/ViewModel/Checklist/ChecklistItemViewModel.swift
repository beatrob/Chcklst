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


class ChecklistItemViewModel: ObservableObject, Identifiable, Equatable {
    
    let id: String
    @Published var name: String = "" {
        didSet {
            onNameChanged.send(name)
        }
    }
    @Published var isDone: Bool = false
    @Published var isEditable: Bool
    
    let onSwipeRight: PassthroughSubject<Void, Never> = .init()
    let onSwipeLeft: PassthroughSubject<Void, Never> = .init()
    let onCheckMarkTapped: PassthroughSubject<Void, Never> = .init()
    let onNameChanged: PassthroughSubject<String, Never> = .init()
    
    var cancellables =  Set<AnyCancellable>()
    
    init(id: String, name: String?, isDone: Bool, isEditable: Bool) {
        self.id = id
        self.name = name ?? ""
        self.isDone = isDone
        self.isEditable = isEditable
    }
    
    init(item: CurrentValueSubject<ChecklistItemDataModel, Never>) {
        self.id = item.value.id
        self.isEditable = false
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
    
    static func == (lhs: ChecklistItemViewModel, rhs: ChecklistItemViewModel) -> Bool {
        lhs.id == rhs.id
    }
}
