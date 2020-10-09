//
//  Template+CoreDataProperties.swift
//  checklist
//
//  Created by Róbert Konczi on 30/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//
//

import Foundation
import CoreData
import PromiseKit


extension TemplateMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TemplateMO> {
        return NSFetchRequest<TemplateMO>(entityName: "Template")
    }
    
    @nonobjc public class func fetchRequest(withId id: String) -> NSFetchRequest<TemplateMO> {
        let request = NSFetchRequest<TemplateMO>(entityName: "Template")
        request.predicate = NSPredicate(format: "identifier == %@", id)
        request.fetchLimit = 1
        return request
    }

    @NSManaged public var identifier: String
    @NSManaged public var title: String
    @NSManaged public var notes: String?
    @NSManaged public var items: ChecklistItemArrayTransformable?
    
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
    
    static func createEntity(from dataModel: TemplateDataModel, andSaveToContext context: NSManagedObjectContext) -> Promise<Void> {
        guard let entity = NSEntityDescription.entity(forEntityName: "Template", in: context) else {
            return .init(error: CoreDataError.createEntityError)
        }
        let templateMO = TemplateMO(entity: entity, insertInto: context)
        templateMO.setup(with: dataModel)
        return .value
    }

}
