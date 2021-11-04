//
//  TemplateMO.swift
//  checklist
//
//  Created by Robert Konczi on 5/30/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit


extension TemplateMO {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TemplateMO> {
        return NSFetchRequest<TemplateMO>(entityName: entityName)
    }
    
    @nonobjc public class func fetchRequest(withId id: String) -> NSFetchRequest<TemplateMO> {
        let request = NSFetchRequest<TemplateMO>(entityName: entityName)
        request.predicate = NSPredicate(format: "identifier == %@", id)
        request.fetchLimit = 1
        return request
    }
    
    func toTemplateDataModel() -> TemplateDataModel {
        .init(
            id: identifier,
            title: title,
            description: notes,
            items: (items as? Set<ItemMO>)?.compactMap { $0.toDataModel() } ?? [],
            created: creationDate
        )
    }
    
    func setup(with dataModel: TemplateDataModel, context: NSManagedObjectContext) {
        identifier = dataModel.id
        title = dataModel.title
        notes = dataModel.description
        creationDate = dataModel.created
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
    
    static func getManagedObject(
        for dataModel: TemplateDataModel,
        context: NSManagedObjectContext
    ) -> Promise<TemplateMO> {
        Promise { resolver in
            let data = try context.fetch(Self.fetchRequest(withId: dataModel.id))
            guard let template = data.first else {
                throw CoreDataError.fetchError
            }
            resolver.fulfill(template)
        }
    }
    
    static func createEntity(
        from dataModel: TemplateDataModel,
        andSaveToContext context: NSManagedObjectContext
    ) -> Promise<TemplateMO> {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            return .init(error: CoreDataError.createEntityError)
        }
        let templateMO = TemplateMO(entity: entity, insertInto: context)
        templateMO.setup(with: dataModel, context: context)
        return .value(templateMO)
    }
}

// MARK: Generated accessors for schedules
extension TemplateMO {

    @objc(addSchedulesObject:)
    @NSManaged public func addToSchedules(_ value: ScheduleMO)

    @objc(removeSchedulesObject:)
    @NSManaged public func removeFromSchedules(_ value: ScheduleMO)

    @objc(addSchedules:)
    @NSManaged public func addToSchedules(_ values: NSSet)

    @objc(removeSchedules:)
    @NSManaged public func removeFromSchedules(_ values: NSSet)

}

// MARK: Generated accessors for items
extension TemplateMO {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: ItemMO)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: ItemMO)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}
