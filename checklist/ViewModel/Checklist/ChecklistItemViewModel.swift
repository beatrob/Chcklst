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
    @Published var isEditModeActive: Bool = false
    
    let onSwipeRight: PassthroughSubject<Void, Never> = .init()
    let onSwipeLeft: PassthroughSubject<Void, Never> = .init()
    let onCheckMarkTapped: PassthroughSubject<Void, Never> = .init()
    let onTextLongPressed = EmptySubject()
    let onTextEditorLongPressed = EmptySubject()
    
    var cancellables =  Set<AnyCancellable>()
    
    init(name: String?, isDone: Bool) {
        self.name = name ?? "TODO "
        self.isDone = isDone
        self.isEditModeActive = name == nil
        
        setupObservers()
    }
    
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
        
        setupObservers()
    }
    
    func setupObservers() {
        onTextLongPressed.sink { [weak self] in
            self?.isEditModeActive = true
        }.store(in: &cancellables)
        
        onTextEditorLongPressed.sink { [weak self] in
            self?.isEditModeActive = false
        }.store(in: &cancellables)
    }
}
