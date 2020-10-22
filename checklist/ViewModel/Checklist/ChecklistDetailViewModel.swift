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


class ChecklistDetailViewModel: ObservableObject {
    
    struct ChecklistVO {
        let title: String
        let description: String?
        var items: [ChecklistItemDataModel]
        
        mutating func setItems(_ items: [ChecklistItemDataModel]) {
            self.items = items
        }
        
        mutating func replaceItem(_ item: ChecklistItemDataModel) {
            items.removeAll { $0.id == item.id }
            items.append(item)
        }
    }
    
    @Published var checklistVO = ChecklistVO(title: "", description: "", items: [])
    
    var cancellables =  Set<AnyCancellable>()
    
    private let checklist: ChecklistCurrentValueSubject
    private let checklistDataSource: ChecklistDataSource
    
    init(checklist: ChecklistCurrentValueSubject, checklistDataSource: ChecklistDataSource) {
        self.checklist = checklist
        self.checklistDataSource = checklistDataSource
        checklist.sink { [weak self] checklist in
            guard let self = self, let checklist = checklist else {
                return
            }
            self.checklistVO = .init(
                title: checklist.title,
                description: checklist.description,
                items: self.reorderItems(checklist.items)
            )
        }.store(in: &cancellables)
    }
    
    func getItemViewModel(for item: ChecklistItemDataModel) -> ChecklistItemViewModel {
        let itemSubject = CurrentValueSubject<ChecklistItemDataModel, Never>(item)
        itemSubject.dropFirst().sink { [weak self] item in
            guard
                let self = self,
                let checklist = self.checklist.value
            else { return }
            self.checklistDataSource.updateItem(item, in: checklist).catch { _ in
                
            }
        }.store(in: &cancellables)
        return .init(item: itemSubject)
    }
    
    func reorderItems(_ items: [ChecklistItemDataModel]) -> [ChecklistItemDataModel] {
        let sortedByDone = items.sorted { (left, right) -> Bool in
            right.isDone
        }
        let undone = sortedByDone.filter(\.isUndone).sorted { (left, right) -> Bool in
            right.updateDate > left.updateDate
        }
        let done = sortedByDone.filter(\.isDone).sorted { (left, right) -> Bool in
            right.updateDate < left.updateDate
        }
        return undone + done
    }
}
