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
    
    
    var _items: [ItemDataModel] = []
    var _checklistToItemIds: [ChecklistDataModel: [String]] = [:]
    var _templateToItemIds: [TemplateDataModel: [String]] = [:]
    
    func getItems(for checklist: ChecklistDataModel) -> Promise<[ItemDataModel]> {
        if let items = _checklistToItemIds[checklist] {
            return .value(items.compactMap { itemId in _items.first { $0.id == itemId } })
        }
        return getMockItems().get { items in
            self._checklistToItemIds[checklist] = items.map { $0.id }
            self._items = items
        }
    }
    
    func getItems(for template: TemplateDataModel) -> Promise<[ItemDataModel]> {
        if let items = _templateToItemIds[template] {
            return .value(items.compactMap { itemId in _items.first { $0.id == itemId } })
        }
        return getMockItems().get { items in
            self._templateToItemIds[template] = items.map { $0.id }
            self._items = items
        }
    }
    
    func update(_ items: [ItemDataModel]) -> Promise<[ItemDataModel]> {
        delete(items).get {
            self._items = items
        }.map {
            items
        }
    }
    
    func delete(_ items: [ItemDataModel]) -> Promise<Void> {
        items.forEach { item in
            _items.removeAll { $0.id == item.id }
        }
        return .value(())
    }
    
    func setItem(_ item: ItemDataModel, isDone: Bool) -> Promise<ItemDataModel> {
        guard _items.contains(item) else {
            return .init(error: DataSourceError.itemNotFound)
        }
        return update(
            [.init(id: item.id, name: item.name, isDone: isDone, updateDate: item.updateDate)]
        ).map { $0.first! }
    }
    
    func saveItems(_ items: [ItemDataModel], for checklist: ChecklistDataModel) -> Promise<[ItemDataModel]> {
        _checklistToItemIds[checklist] = items.map { $0.id }
        _items = items
        return .value(items)
    }
    
    func saveItem(_ items: [ItemDataModel], for template: TemplateDataModel) -> Promise<[ItemDataModel]> {
        _templateToItemIds[template] = items.map { $0.id }
        _items = items
        return .value(items)
    }
}


private extension MockItemDataSource {
    
    private func getMockItems() -> Guarantee<[ItemDataModel]> {
        .value(
            [
                .init(
                    id: UUID().uuidString,
                    name: "Mock item 1",
                    isDone: false,
                    updateDate: Date().addingTimeInterval(1)
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Another item 2",
                    isDone: false,
                    updateDate: Date().addingTimeInterval(1)
                ),
                .init(
                    id: UUID().uuidString,
                    name: "A final mock item 3",
                    isDone: false,
                    updateDate: Date().addingTimeInterval(1)
                )
            ]
        )
    }
}
