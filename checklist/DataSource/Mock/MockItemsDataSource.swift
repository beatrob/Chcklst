//
//  MockItemsDataSource.swift
//  checklist
//
//  Created by Robert Konczi on 11/1/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import PromiseKit


class MockItemDataSource: ItemDataSource {
    
    func setItem(_ item: ItemDataModel, done: Bool) -> Promise<ItemDataModel> {
        .value(.init(id: item.id, name: item.name, isDone: done, updateDate: Date()))
    }
}
