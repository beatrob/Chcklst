//
//  CreateChecklistViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 19/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


class CreateChecklistViewModel: ObservableObject {
    
    @Published var shouldCreateChecklistName: Bool = true {
        didSet {
            shouldDisplayAddItems = !shouldCreateChecklistName
        }
    }
    @Published var shouldDisplayAddItems: Bool = false
    @Published var checklistName: String = ""
    let onCreateFromTemplate: EmptySubject = .init()
    let onCreateTitleNext: EmptySubject = .init()
    
    var cancellables =  Set<AnyCancellable>()
    
    init(createChecklistSubject: CreateChecklistSubject) {
        onCreateTitleNext.sink { [weak self] in
            self?.shouldCreateChecklistName = false
        }.store(in: &cancellables)
    }
}
