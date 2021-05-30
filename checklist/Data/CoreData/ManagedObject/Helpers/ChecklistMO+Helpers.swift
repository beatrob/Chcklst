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
            updateDate: updateDate,
            reminderDate: reminderDate,
            items: items?.getItemDataModels() ?? []
        )
    }
    
    func setup(with dataModel: ChecklistDataModel) {
        identifier = dataModel.id
        title = dataModel.title
        notes = dataModel.description
        updateDate = dataModel.updateDate
        reminderDate = dataModel.reminderDate
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
