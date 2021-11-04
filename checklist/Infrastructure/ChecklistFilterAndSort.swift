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
    var searchResults: AnyPublisher<[ChecklistDataModel], Never> { get }
    var sort: SortDataModel { get set }
    var filter: FilterDataModel? { get set }
    var search: String? { get set }
    var isSearching: Bool { get }
    var isFiltering: Bool { get }
}

class ChecklistFilterAndSortImpl: ChecklistFilterAndSort {
    
    private let checklistDataSource: ChecklistDataSource

    private let _filteredChecklists = PassthroughSubject<[ChecklistDataModel], Never>()
    private let _searchResults = PassthroughSubject<[ChecklistDataModel], Never>()
    
    var filteredAndSortedCheckLists: AnyPublisher<[ChecklistDataModel], Never> {
        _filteredChecklists.eraseToAnyPublisher()
    }
    
    var searchResults: AnyPublisher<[ChecklistDataModel], Never> {
        _searchResults.eraseToAnyPublisher()
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
    
    var search: String? {
        didSet {
            updateFilterAndSort()
        }
    }
    
    var isSearching: Bool { search != nil }
    
    var isFiltering: Bool {
        guard let filter = filter else {
            return false
        }
        return filter != .none
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(dataSource: ChecklistDataSource) {
        self.checklistDataSource = dataSource
    }
    
    private func updateFilterAndSort() {
        cancellables.removeAll()
        checklistDataSource.checkLists
            .filter { [weak self] _ in !(self?.isSearching ?? false) }
            .map { [weak self] in self?.filter(checklists: $0) ?? $0 }
            .map { [weak self] in self?.sort(checklists: $0) ?? $0 }
            .subscribe(_filteredChecklists)
            .store(in: &cancellables)
        
        checklistDataSource.checkLists
            .filter { [weak self] _ in self?.isSearching ?? false }
            .map { [weak self] in self?.search(checklists: $0) ?? $0 }
            .subscribe(_searchResults)
            .store(in: &cancellables)        
    }
    
    private func search(checklists: [ChecklistDataModel]) -> [ChecklistDataModel]? {
        guard let searchText = self.search?.lowercased() else {
            return nil
        }
        return checklists.filter { checklist -> Bool in
            checklist.title.lowercased().contains(searchText) ||
                checklist.description?.lowercased().contains(searchText) ?? false
        }
    }
    
    private func filter(checklists: [ChecklistDataModel]) -> [ChecklistDataModel] {
        guard let filter = filter else {
            return checklists
        }
        switch filter {
        case .none: return checklists
        case .done: return filterDone(checklists: checklists)
        case .withReminder: return filterReminders(checklists: checklists)
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
}
