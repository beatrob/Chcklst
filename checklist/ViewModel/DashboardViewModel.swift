//
//  DashboardViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


class DashboardViewModel: ObservableObject {
    
    struct ChecklistVO {
        let id: String
        let title: String
        let firstItem: String
        let counter: String
        let isDone: Bool
    }
    
    @Published var checklists: [ChecklistVO] = [] {
        didSet {
            self.objectWillChange.send()
        }
    }
    
    var cancellables =  Set<AnyCancellable>()
    
    private let checklistDataSource: ChecklistDataSource
    
    init(checklistDataSource: ChecklistDataSource) {
        self.checklistDataSource = checklistDataSource
        
        checklistDataSource.checkLists.sink {
            self.handleChecklistData($0)
        }.store(in: &cancellables)
    }
    
    func handleChecklistData(_ checklists: [ChecklistDataModel]) {
        self.checklists =  checklists.map {
            ChecklistVO(
                id: $0.id,
                title: $0.title,
                firstItem: $0.items.first?.name ?? "",
                counter: "\($0.items.filter(\.isDone).count)/\($0.items.count)",
                isDone: $0.isDone
            )
        }
    }
}
