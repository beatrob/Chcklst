//
//  Checklist+CoreDataProperties.swift
//  checklist
//
//  Created by Róbert Konczi on 27/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//
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

    @NSManaged public var identifier: String
    @NSManaged public var title: String
    @NSManaged public var notes: String?
    @NSManaged public var updateDate: Date
    @NSManaged public var items: ChecklistItemArrayTransformable?
    
    func toChecklistDataModel() -> ChecklistDataModel {
        .init(
            id: identifier,
            title: title,
            description: notes,
            updateDate: updateDate,
            items: items?.getItemDataModels() ?? []
        )
    }
    
    func setup(with dataModel: ChecklistDataModel) {
        identifier = dataModel.id
        title = dataModel.title
        notes = dataModel.description
        updateDate = dataModel.updateDate
        items = ChecklistItemArrayTransformable(checklistItems: dataModel.items)
    }
    
    static func createEntity(from dataModel: ChecklistDataModel, andSaveToContext context: NSManagedObjectContext) -> Promise<Void> {
        guard let entity = NSEntityDescription.entity(forEntityName: "Checklist", in: context) else {
            return .init(error: CoreDataError.createEntityError)
        }
        let checklistMO = ChecklistMO(entity: entity, insertInto: context)
        checklistMO.setup(with: dataModel)
        return .value
    }
}
