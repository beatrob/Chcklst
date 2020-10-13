//
//  ChecklistFilter.swift
//  checklist
//
//  Created by Róbert Konczi on 09/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine


protocol ChecklistFilter: AnyObject {
    var filteredCheckLists: AnyPublisher<[ChecklistDataModel], Never> { get }
    var filter: FilterItemData { get set }
}

class ChecklistFilterImpl: ChecklistFilter {
    
    private let dataSource: ChecklistDataSource
    private let _filteredChecklists = PassthroughSubject<[ChecklistDataModel], Never>()
    var filteredCheckLists: AnyPublisher<[ChecklistDataModel], Never> {
        _filteredChecklists.eraseToAnyPublisher()
    }
    
    var filter: FilterItemData {
        didSet {
            dataSource.checkLists.sink { [weak self] checklists in
                guard let self = self else { return }
                self._filteredChecklists.send(self.filter(checklists: checklists))
            }.store(in: &cancellables)
        }
    }
    
    var cancellables = Set<AnyCancellable>()
    
    init(dataSource: ChecklistDataSource) {
        self.dataSource = dataSource
        self.filter = .initial
    }
    
    private func filter(checklists: [ChecklistDataModel]) -> [ChecklistDataModel] {
        switch filter {
        case .latest: return orderByLatest(checklists: checklists)
        case .abc: return orderByAlphabet(checklists: checklists)
        case .done:
            let doneOnly = filterDone(checklists: checklists)
            return orderByLatest(checklists: doneOnly)
        case .reminder:
            let reminderOnly = filterReminders(checklists: checklists)
            return orderByLatest(checklists: reminderOnly)
        case .archive:
            let archivedOnly = filterArchived(checklists: checklists)
            return orderByLatest(checklists: archivedOnly)
        }
    }
    
    private func orderByLatest(checklists: [ChecklistDataModel]) -> [ChecklistDataModel] {
        checklists.sorted { (left, right) -> Bool in
            left.updateDate > right.updateDate
        }
    }
    
    private func orderByAlphabet(checklists: [ChecklistDataModel]) -> [ChecklistDataModel] {
        checklists.sorted { (left, right) -> Bool in
            left.title.localizedCaseInsensitiveCompare(right.title) == .orderedAscending
        }
    }
    
    private func filterDone(checklists: [ChecklistDataModel]) -> [ChecklistDataModel] {
        checklists.filter { $0.isDone }
    }
    
    private func filterReminders(checklists: [ChecklistDataModel]) -> [ChecklistDataModel] {
        checklists.filter { $0.isValidReminderSet }
    }
    
    private func filterArchived(checklists: [ChecklistDataModel]) -> [ChecklistDataModel] {
        checklists.filter { $0.isArchived }
    }
}
