//
//  ChecklistViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 14/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


class ChecklistViewModel: ObservableObject {
    
    struct ChecklistVO {
        struct ItemVO {
            let name: String
            let isDone: Bool
        }
        let title: String
        let description: String
        let items: [ItemVO]
    }
    
    @Published var checklistVO = ChecklistVO(title: "", description: "", items: [])
    
    var cancellables =  Set<AnyCancellable>()
    
    init(checklist: AnyPublisher<ChecklistDataModel, Never>) {
        checklist.sink { [weak self] checklist in
            self?.checklistVO = .init(
                title: checklist.title,
                description: checklist.description,
                items: checklist.items.map {
                    ChecklistVO.ItemVO(name: $0.name, isDone: $0.isDone)
                }
            )
        }.store(in: &cancellables)
    }
}
