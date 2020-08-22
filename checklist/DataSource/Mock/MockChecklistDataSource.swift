//
//  MockChecklistDataSource.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine


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
    
    let createNewChecklist: CreateChecklistSubject = .init()
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
        
        createNewChecklist.sink { [weak self] checklist in
            guard let self = self else { return }
            self._checkLists.value.insert(checklist, at: 0)
        }.store(in: &cancellables)
    }
    
    func updateItem(
        _ item: ChecklistItemDataModel,
        for checkList: ChecklistDataModel,
        _ completion: @escaping (Result<Void, DataSourceError>) -> Void
    ) {
        guard let index = _checkLists.value.firstIndex(of: checkList) else {
            completion(.failure(.checkListNotFound))
            return
        }
        if _checkLists.value[index].items.updateItem(item) {
            completion(.success(()))
        }
        completion(.failure(.checkListItemNotFound))
    }
}
