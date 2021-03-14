//
//  MockChecklistDataSource.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import PromiseKit


class MockChecklistDataSource: ChecklistDataSource {

    var _checkLists: CurrentValueSubject<[ChecklistDataModel], Never> = .init([
        .init(
            id: "1",
            title: "My first check-list",
            description: "My first super cool checklist to do stuff efficiently",
            updateDate: Date(),
            items: [
                .init(id: "1", name: "Do this for the first.", isDone: false, updateDate: Date()),
                .init(id: "2", name: "Do this for the second.", isDone: false, updateDate: Date().addingTimeInterval(1)),
                .init(id: "3", name: "Do this for the third.", isDone: false, updateDate: Date().addingTimeInterval(2)),
                .init(id: "4", name: "Do this for the fourth.", isDone: false, updateDate: Date().addingTimeInterval(3)),
                .init(id: "5", name: "Do this for the fifth.", isDone: false, updateDate: Date().addingTimeInterval(4)),
                .init(id: "6", name: "Do this for the sixth.", isDone: false, updateDate: Date().addingTimeInterval(5))
            ]
        ),
        .init(
            id: "2",
            title: "My second check-list",
            description: "My second super cool checklist to do stuff efficiently",
            updateDate: Date(),
            items: [
                .init(id: "1", name: "Something something something.", isDone: true, updateDate: Date()),
                .init(id: "2", name: "Do this for the second.", isDone: false, updateDate: Date().addingTimeInterval(1)),
                .init(id: "3", name: "Do this for the third.", isDone: true, updateDate: Date().addingTimeInterval(2)),
                .init(id: "4", name: "Do this for the fourth.", isDone: false, updateDate: Date().addingTimeInterval(3)),
                .init(id: "5", name: "Do this for the fifth.", isDone: false, updateDate: Date().addingTimeInterval(4)),
                .init(id: "6", name: "Do this for the sixth.", isDone: true, updateDate: Date().addingTimeInterval(5))
            ]
        ),
        .init(
            id: "3",
            title: "My third check-list",
            description: "My first super cool checklist to do stuff efficiently",
            updateDate: Date(),
            items: [
                .init(id: "1", name: "Lala blah blah blah.", isDone: false, updateDate: Date()),
                .init(id: "2", name: "Do this for the second.", isDone: false, updateDate: Date().addingTimeInterval(1)),
                .init(id: "3", name: "Do this for the third.", isDone: false, updateDate: Date().addingTimeInterval(2)),
                .init(id: "4", name: "Do this for the fourth.", isDone: true, updateDate: Date().addingTimeInterval(3)),
                .init(id: "5", name: "Do this for the fifth.", isDone: false, updateDate: Date().addingTimeInterval(4)),
                .init(id: "6", name: "Do this for the sixth.", isDone: false, updateDate: Date().addingTimeInterval(5))
            ]
        )
    ])
    
    let selectedCheckList: CurrentValueSubject<ChecklistDataModel?, Never> = .init(nil)
    var cancellables =  Set<AnyCancellable>()
    
    var checkLists: AnyPublisher<[ChecklistDataModel], Never> {
        _checkLists.eraseToAnyPublisher()
    }
    
    init() {
        selectedCheckList.dropFirst().sink { [weak self] checklist in
            guard let self = self else { return }
            guard var checklist = checklist else { return }
            checklist.updateDate = Date()
            _ = self._checkLists.value.updateItem(checklist)
        }.store(in: &cancellables)
    }
    
    func updateItem(_ item: ChecklistItemDataModel, in checkList: ChecklistDataModel) -> Promise<Void> {
        guard let index = _checkLists.value.firstIndex(of: checkList) else {
            return .init(error: DataSourceError.checkListNotFound)
        }
        if _checkLists.value[index].items.updateItem(item) {
            return .value
        }
        return .init(error: DataSourceError.checkListItemNotFound)
    }
    
    func updateReminderDate(_ date: Date?, for checklist: ChecklistDataModel) -> Promise<Void> {
        guard let index = _checkLists.value.firstIndex(of: checklist) else {
            return .init(error: DataSourceError.checkListNotFound)
        }
        _checkLists.value[index].reminderDate = date
        return .value
    }
    
    func loadAllChecklists() -> Promise<[ChecklistDataModel]> {
        .value(_checkLists.value)
    }
    
    func getChecklist(withId id: String) -> ChecklistDataModel? {
        _checkLists.value.first { $0.id == id }
    }
    
    func createChecklist(_ checklist: ChecklistDataModel) -> Promise<Void> {
        _checkLists.value.insert(checklist, at: 0)
        return .value
    }
    
    func deleteChecklist(_ checklist: ChecklistDataModel) -> Promise<Void> {
        _checkLists.value.removeAll { $0.id == checklist.id }
        return .value
    }
    
    func deleteExpiredNotificationDates() -> Promise<Void> {
        .value
    }
    
    func updateChecklist(_ checklist: ChecklistDataModel) -> Promise<Void> {
        .value
    }
}
