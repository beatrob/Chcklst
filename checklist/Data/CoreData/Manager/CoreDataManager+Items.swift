//
//  CoreDataManager+Items.swift
//  checklist
//
//  Created by Robert Konczi on 11/3/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import PromiseKit


extension CoreDataManagerImpl: CoreDataItemManager {
    
    func save(_ item: ItemDataModel) -> Promise<Void> {
        getViewContext().get { context in
            let item = try ItemMO.getManagedObject(for: item, context: context)
            item.checklist?.updateDate = Date()
        }.asVoid().then {
            self.saveContext()
        }
    }
}
