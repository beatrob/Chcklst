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


class ChecklistItemViewModel: ObservableObject, Identifiable, Equatable, Hashable {
    
    let id: String
    @Published var name: String = "" {
        didSet {
            onNameChanged.send(name)
        }
    }
    @Published var isDone: Bool
    @Published var isEditable: Bool
    var updateDate: Date
    var isCheckable: Bool
    
    let onLongPress = EmptySubject()
    let onCheckMarkTapped = EmptySubject()
    let onNameChanged: PassthroughSubject<String, Never> = .init()
    let onDidEndEditing = EmptySubject()
    let onDidChangeDoneState = PassthroughSubject<Bool, Never>()
    var onTextDidClear: EmptyPublisher {
        onDidEndEditing
            .combineLatest($name)
            .map { $0.1.isEmpty }
            .filter { $0 }
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    var cancellables =  Set<AnyCancellable>()
    
    init(item: ItemDataModel, isEditable: Bool, isCheckable: Bool, itemDataSource: ItemDataSource) {
        self.id = item.id
        self.name = item.name
        self.isDone = item.isDone
        self.isEditable = isEditable
        self.updateDate = item.updateDate
        self.isCheckable = isCheckable
        
        onCheckMarkTapped
            .merge(with: onLongPress)
            .sink { [weak self] in
                guard let self = self, self.isCheckable else {
                    return
                }
                self.isDone.toggle()
                Haptics.play(.itemDoneUndone)
                itemDataSource.setItem(item, done: self.isDone).done { i in
                    self.updateDate = i.updateDate
                    self.onDidChangeDoneState.send(i.isDone)
                }.catch { error in
                    error.log(message: "Failed to update done/undone item")
                }
            }
            .store(in: &cancellables)
    }
    
    static func == (lhs: ChecklistItemViewModel, rhs: ChecklistItemViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
