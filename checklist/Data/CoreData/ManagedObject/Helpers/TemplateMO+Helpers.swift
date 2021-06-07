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
            items: items?.getItemDataModels() ?? []
        )
    }
    
    func setup(with dataModel: TemplateDataModel) {
        identifier = dataModel.id
        title = dataModel.title
        notes = dataModel.description
        items = ChecklistItemArrayTransformable(checklistItems: dataModel.items)
    }
    
    static func createEntity(
        from dataModel: TemplateDataModel,
        andSaveToContext context: NSManagedObjectContext
    ) -> Promise<TemplateMO> {
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            return .init(error: CoreDataError.createEntityError)
        }
        let templateMO = TemplateMO(entity: entity, insertInto: context)
        templateMO.setup(with: dataModel)
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
