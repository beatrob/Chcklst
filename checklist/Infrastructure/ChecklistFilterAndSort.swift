//
//  ChecklistFilter.swift
//  checklist
//
//  Created by Róbert Konczi on 09/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine


protocol ChecklistFilterAndSort: AnyObject {
    var filteredAndSortedCheckLists: AnyPublisher<[ChecklistDataModel], Never> { get }
    var sort: SortDataModel { get set }
    var filter: FilterDataModel? { get set }
}

class ChecklistFilterAndSortImpl: ChecklistFilterAndSort {
    
    private let dataSource: ChecklistDataSource
    private let _filteredChecklists = PassthroughSubject<[ChecklistDataModel], Never>()
    
    var filteredAndSortedCheckLists: AnyPublisher<[ChecklistDataModel], Never> {
        _filteredChecklists.eraseToAnyPublisher()
    }
    
    var sort: SortDataModel = .initial {
        didSet {
            updateFilterAndSort()
        }
    }
    
    var filter: FilterDataModel? {
        didSet {
            updateFilterAndSort()
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(dataSource: ChecklistDataSource) {
        self.dataSource = dataSource
    }
    
    private func updateFilterAndSort() {
        cancellables.removeAll()
        dataSource.checkLists.sink { [weak self] checklists  in
            guard let self = self else { return }
            let filtered = self.filter(checklists: checklists)
            let sorted = self.sort(checklists: filtered)
            self._filteredChecklists.send(sorted)
        }.store(in: &cancellables)
    }
    
    private func filter(checklists: [ChecklistDataModel]) -> [ChecklistDataModel] {
        guard let filter = filter else {
            return checklists
        }
        switch filter {
        case .none: return checklists
        case .done: return filterDone(checklists: checklists)
        case .withReminder: return filterReminders(checklists: checklists)
        case .archived: return filterArchived(checklists: checklists)
        }
    }
    
    private func sort(checklists: [ChecklistDataModel]) -> [ChecklistDataModel] {
        switch sort {
        case .latest: return orderByLatest(checklists: checklists)
        case .oldest: return orderByLatest(checklists: checklists).reversed()
        case .nameAsc: return orderByAlphabet(checklists: checklists, ascending: true)
        case .nameDesc: return orderByAlphabet(checklists: checklists, ascending: false)
        }
    }
    
    
    private func orderByLatest(checklists: [ChecklistDataModel]) -> [ChecklistDataModel] {
        checklists.sorted { (left, right) -> Bool in
            left.updateDate > right.updateDate
        }
    }
    
    private func orderByAlphabet(checklists: [ChecklistDataModel], ascending: Bool) -> [ChecklistDataModel] {
        checklists.sorted { (left, right) -> Bool in
            left.title.localizedCaseInsensitiveCompare(right.title) ==  (ascending ? .orderedAscending : .orderedDescending)
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
