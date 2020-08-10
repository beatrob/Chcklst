//
//  MockChecklistDataSource.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import PromiseKit


class MockChecklistDataSource: ChecklistDataSource {
    
    var checkLists: [ChecklistDataModel] = [
        .init(
            id: "1",
            title: "My first check-list",
            description: "My first super cool checklist to do stuff efficiently",
            items: [
                .init(id: "1", name: "Do this for the first.", isDone: false, updateDate: Date()),
                .init(id: "2", name: "Do this for the second.", isDone: false, updateDate: Date()),
                .init(id: "3", name: "Do this for the third.", isDone: false, updateDate: Date()),
                .init(id: "4", name: "Do this for the fourth.", isDone: false, updateDate: Date()),
                .init(id: "5", name: "Do this for the fifth.", isDone: false, updateDate: Date()),
                .init(id: "6", name: "Do this for the sixth.", isDone: false, updateDate: Date())
            ]
        ),
        .init(
            id: "2",
            title: "My second check-list",
            description: "My second super cool checklist to do stuff efficiently",
            items: [
                .init(id: "1", name: "Something something something.", isDone: true, updateDate: Date()),
                .init(id: "2", name: "Do this for the second.", isDone: false, updateDate: Date()),
                .init(id: "3", name: "Do this for the third.", isDone: true, updateDate: Date()),
                .init(id: "4", name: "Do this for the fourth.", isDone: false, updateDate: Date()),
                .init(id: "5", name: "Do this for the fifth.", isDone: false, updateDate: Date()),
                .init(id: "6", name: "Do this for the sixth.", isDone: true, updateDate: Date())
            ]
        ),
        .init(
            id: "3",
            title: "My third check-list",
            description: "My first super cool checklist to do stuff efficiently",
            items: [
                .init(id: "1", name: "Lala blah blah blah.", isDone: false, updateDate: Date()),
                .init(id: "2", name: "Do this for the second.", isDone: false, updateDate: Date()),
                .init(id: "3", name: "Do this for the third.", isDone: false, updateDate: Date()),
                .init(id: "4", name: "Do this for the fourth.", isDone: true, updateDate: Date()),
                .init(id: "5", name: "Do this for the fifth.", isDone: false, updateDate: Date()),
                .init(id: "6", name: "Do this for the sixth.", isDone: false, updateDate: Date())
            ]
        )
    ]
    
    func getActiveChecklists() -> Promise<[ChecklistDataModel]> {
        .value(checkLists)
    }
}
