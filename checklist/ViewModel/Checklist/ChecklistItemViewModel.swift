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
    
    convenience init(item: ChecklistItemDataModel, checklistDataSource: ChecklistDataSource) {
        self.init(
            id: item.id,
            name: item.name,
            isDone: item.isDone,
            isEditable: false
        )
        self.updateDate = item.updateDate
        onCheckMarkTapped
            .merge(with: onLongPress)
            .sink { [weak self] in
                guard let self = self else {
                    return
                }
                self.updateDate = Date()
                self.isDone.toggle()
                Haptics.play(.itemDoneUndone)
                checklistDataSource.updateItem(item, isDone: self.isDone).done {
                    self.onDidChangeDoneState.send(self.isDone)
                }.catch { error in
                    error.log(message: "Failed to update done/undone item")
                }
            }
            .store(in: &cancellables)
    }
    
    static func == (lhs: ChecklistItemViewModel, rhs: ChecklistItemViewModel) -> Bool {
        lhs.id == rhs.id
    }
}
