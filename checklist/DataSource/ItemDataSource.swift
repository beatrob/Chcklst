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
    
    func getItems(for checklist: ChecklistDataModel) -> Promise<[ItemDataModel]>
    func getItems(for template: TemplateDataModel) -> Promise<[ItemDataModel]>
    func update(_ items: [ItemDataModel]) -> Promise<[ItemDataModel]>
    func delete(_ items: [ItemDataModel]) -> Promise<Void>
    func setItem(_ item: ItemDataModel, isDone: Bool) -> Promise<ItemDataModel>
    func saveItems(_ items: [ItemDataModel], for checklist: ChecklistDataModel) -> Promise<[ItemDataModel]>
    func saveItem(_ items: [ItemDataModel], for template: TemplateDataModel) -> Promise<[ItemDataModel]>
}
