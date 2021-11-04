//
//  ChecklitsMO.swift
//  checklist
//
//  Created by Robert Konczi on 5/30/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit


extension ChecklistMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChecklistMO> {
        return NSFetchRequest<ChecklistMO>(entityName: "Checklist")
    }
    
    @nonobjc public class func fetchRequest(withId id: String) -> NSFetchRequest<ChecklistMO> {
        let request = NSFetchRequest<ChecklistMO>(entityName: "Checklist")
        request.predicate = NSPredicate(format: "identifier == %@", id)
        request.fetchLimit = 1
        return request
    }
    
    func toChecklistDataModel() -> ChecklistDataModel {
        .init(
            id: identifier,
            title: title,
            description: notes,
            creationDate: creationDate,
            updateDate: updateDate,
            reminderDate: reminderDate,
            items: getItems().map { $0.toDataModel() }
        )
    }
    
    func setup(with dataModel: ChecklistDataModel, context: NSManagedObjectContext) {
        identifier = dataModel.id
        title = dataModel.title
        notes = dataModel.description
        updateDate = dataModel.updateDate
        creationDate = dataModel.creationDate
        reminderDate = dataModel.reminderDate
        do {
            let oldItems = items
            let newItems = Set(try dataModel.items.map {
                try ItemMO.getManagedObject(for: $0, context: context)
            })
            if oldItems?.count ?? 0 > 0 {
                (oldItems as! Set<ItemMO>).subtracting(newItems).forEach { item in
                    context.delete(item)
                }
            }
            items = newItems as NSSet
        } catch {
            error.log(message: "Failed to get ItemMO")
        }
    }
    
    static func createEntity(from dataModel: ChecklistDataModel, andSaveToContext context: NSManagedObjectContext) -> Promise<Void> {
        guard let entity = NSEntityDescription.entity(forEntityName: "Checklist", in: context) else {
            return .init(error: CoreDataError.createEntityError)
        }
        let checklistMO = ChecklistMO(entity: entity, insertInto: context)
        checklistMO.setup(with: dataModel, context: context)
        return .value
    }
    
    private func getItems() -> [ItemMO] {
        items?.allObjects as? [ItemMO] ?? []
    }
}

// MARK: Generated accessors for items
extension ChecklistMO {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: ItemMO)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: ItemMO)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}
