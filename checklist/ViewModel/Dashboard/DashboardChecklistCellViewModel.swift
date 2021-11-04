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
    let checklistDataSource: ChecklistDataSource
    let itemDataSource: ItemDataSource
    
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
    
    init(
        checklist: ChecklistDataModel,
        checklistDataSource: ChecklistDataSource,
        itemDataSource: ItemDataSource
    ) {
        self.checklist = checklist
        self.checklistDataSource = checklistDataSource
        self.itemDataSource = itemDataSource
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
        shouldShowNewBadge = checklist.creationDate == checklist.updateDate
        shouldDisplayDeleteButton = checklist.isDone
        shouldStrikeThroughTitle = checklist.isDone
        firstUndoneItem = getItemViewModel(for: getFirstUndoneItem())
    }
    
    func getItemViewModel(for item: ItemDataModel?) -> ChecklistItemViewModel? {
        guard let item = item else {
            return nil
        }
        let viewModel = ChecklistItemViewModel(
            item: item,
            itemDataSource: AppContext.resolver.resolve(ItemDataSource.self)!
        )
        
        viewModel.onDidChangeDoneState
            .sink { [weak self] isDone in
                guard let self = self else {
                    return
                }
                self.checklistDataSource.reloadChecklist(self.checklist).get {
                    self.checklist = $0
                }.catch { error in
                    error.log(message: "Faied to update Checklist")
                }
            }
            .store(in: &cancellables)
        
        return viewModel
    }
    
    func getFirstUndoneItem() -> ItemDataModel? {
        checklist.items
            .filter(\.isUndone)
            .sorted { (left, right) -> Bool in left.updateDate < right.updateDate }
            .first
    }
}
