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
    @Published var isDone: Bool
    @Published var isEditable: Bool
    var updateDate: Date
    
    let onSwipeRight: PassthroughSubject<Void, Never> = .init()
    let onSwipeLeft: PassthroughSubject<Void, Never> = .init()
    let onCheckMarkTapped: PassthroughSubject<Void, Never> = .init()
    let onNameChanged: PassthroughSubject<String, Never> = .init()
    let onDidEndEditing: PassthroughSubject<Void, Never> = .init()
    var onTextDidClear: EmptyPublisher {
        onDidEndEditing
            .combineLatest($name)
            .map { $0.1.isEmpty }
            .filter { $0 }
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    var cancellables =  Set<AnyCancellable>()
    
    static var empty: ChecklistItemViewModel {
        .init(id: "", name: nil, isDone: false, isEditable: false)
    }
    
    init(id: String, name: String?, isDone: Bool, isEditable: Bool) {
        self.id = id
        self.name = name ?? ""
        self.isDone = isDone
        self.isEditable = isEditable
        self.updateDate = Date()
    }
    
    convenience init(item: CurrentValueSubject<ChecklistItemDataModel, Never>) {
        self.init(
            id: item.value.id,
            name: item.value.name,
            isDone: item.value.isDone,
            isEditable: false
        )
        item.sink { [weak self] i in
            self?.update(name: i.name, isDone: i.isDone, updateDate: i.updateDate)
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


private extension ChecklistItemViewModel {
    
    func update(name: String, isDone: Bool, updateDate: Date) {
        self.name = name
        self.isDone = isDone
        self.updateDate = updateDate
    }
}
