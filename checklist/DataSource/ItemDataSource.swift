//
//  ItemDataSource.swift
//  checklist
//
//  Created by Robert Konczi on 11/1/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import PromiseKit


protocol ItemDataSource {
    
    func setItem(_ item: ItemDataModel, done: Bool) -> Promise<ItemDataModel>
}


class ItemDataSourceImpl: ItemDataSource {
    
    private let coreDataManager: CoreDataItemManager
    
    init(coreDataManager: CoreDataItemManager) {
        self.coreDataManager = coreDataManager
    }
    
    func setItem(_ item: ItemDataModel, done: Bool) -> Promise<ItemDataModel> {
        let newItem = ItemDataModel(
            id: item.id,
            name: item.name,
            isDone: done,
            updateDate: Date()
        )
        return coreDataManager.save(newItem).map { newItem }
    }
}
