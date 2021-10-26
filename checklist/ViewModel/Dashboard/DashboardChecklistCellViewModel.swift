//
//  DashboardChecklistCellViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 12.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine


class DashboardChecklistCellViewModel: ObservableObject, Identifiable {
    
    var id: String {
        get {
            checklist.id
        }
    }
    
    var checklist: ChecklistDataModel {
        didSet {
            setup()
        }
    }
    
    @Published var title: String = ""
    @Published var counter: String = ""
    @Published var isReminderSet: Bool = false
    @Published var shouldShowNewBadge: Bool = false
    @Published var shouldDisplayDeleteButton: Bool = false
    @Published var firstUndoneItem: ChecklistItemViewModel?
    @Published var shouldStrikeThroughTitle = false
    
    let onLongTapped = EmptySubject()
    let onTapped = EmptySubject()
    let onDelete = EmptySubject()
    let onUpdateItem = ChecklistItemPassthroughSubject()
    
    var onChecklistTapped: AnyPublisher<ChecklistDataModel, Never> {
        onTapped.map { [unowned self] in self.checklist }.eraseToAnyPublisher()
    }
    
    var onChecklistLongTapped: AnyPublisher<ChecklistDataModel, Never> {
        onLongTapped.map { [unowned self] in self.checklist }.eraseToAnyPublisher()
    }
    
    var onDeleteCheklistTapped: AnyPublisher<ChecklistDataModel, Never> {
        onDelete.map { [unowned self] in self.checklist }.eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(checklist: ChecklistDataModel) {
        self.checklist = checklist
        setup()
    }
    
    func update(with checklist: ChecklistDataModel) {
        self.checklist = checklist
    }
}


// MARK: - Private methods

private extension DashboardChecklistCellViewModel {
    
    func setup() {
        title = checklist.title
        counter = "\(checklist.items.filter(\.isDone).count)/\(checklist.items.count)"
        isReminderSet = checklist.isValidReminderSet
        firstUndoneItem = getItemViewModel(for: getFirstUndoneItem())
        shouldShowNewBadge = checklist.creationDate == checklist.updateDate
        shouldDisplayDeleteButton = checklist.isDone
        shouldStrikeThroughTitle = checklist.isDone
    }
    
    func getItemViewModel(for item: ChecklistItemDataModel?) -> ChecklistItemViewModel? {
        guard let item = item else {
            return nil
        }
        let itemSubject = CurrentValueSubject<ChecklistItemDataModel, Never>(item)
        itemSubject.dropFirst().sink { [weak self] item in
            self?.onUpdateItem.send(item)
        }.store(in: &cancellables)
        return .init(item: itemSubject)
    }
    
    func getFirstUndoneItem() -> ChecklistItemDataModel? {
        checklist.items
            .filter(\.isUndone)
            .sorted { (left, right) -> Bool in right.updateDate > left.updateDate }
            .first
    }
}
