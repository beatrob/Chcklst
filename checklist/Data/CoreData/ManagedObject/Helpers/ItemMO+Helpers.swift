//
//  Item+CoreDataProperties.swift
//  checklist
//
//  Created by Robert Konczi on 11/2/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//
//

import Foundation
import CoreData


extension ItemMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemMO> {
        return NSFetchRequest<ItemMO>(entityName: "Item")
    }
    
    @nonobjc public class func fetchRequest(withId id: String) -> NSFetchRequest<ItemMO> {
        let request = NSFetchRequest<ItemMO>(entityName: "Item")
        request.predicate = NSPredicate(format: "identifier == %@", id)
        request.fetchLimit = 1
        return request
    }

    @NSManaged public var isDone: Bool
    @NSManaged public var identifier: String
    @NSManaged public var title: String
    @NSManaged public var updateDate: Date
    @NSManaged public var checklist: ChecklistMO?
    @NSManaged public var template: TemplateMO?
    
    func setup(with item: ItemDataModel) {
        self.identifier = item.id
        self.updateDate = item.updateDate
        self.isDone = item.isDone
        self.title = item.name
    }
    
    func toDataModel() -> ItemDataModel {
        .init(
            id: identifier,
            name: title,
            isDone: isDone,
            updateDate: updateDate
        )
    }
    
    static func getManagedObject(for item: ItemDataModel, context: NSManagedObjectContext) throws -> ItemMO {
        let data = try context.fetch(ItemMO.fetchRequest(withId: item.id))
        if let itemMO = data.first {
            itemMO.setup(with: item)
            return itemMO
        } else {
            return try createEntity(from: item, context: context)
        }
    }
    
    private static func createEntity(
        from item: ItemDataModel,
        context: NSManagedObjectContext
    ) throws -> ItemMO {
        guard let entity = NSEntityDescription.entity(forEntityName: "Item", in: context) else {
            throw CoreDataError.createEntityError
        }
        let itemMO = ItemMO(entity: entity, insertInto: context)
        itemMO.setup(with: item)
        return itemMO
    }
}
