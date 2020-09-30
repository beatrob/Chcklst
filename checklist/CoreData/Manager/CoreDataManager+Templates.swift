//
//  CoreDataManager+Checklists.swift
//  checklist
//
//  Created by Róbert Konczi on 27/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import PromiseKit
import CoreData


extension CoreDataManagerImpl: CoreDataTemplateManager {
    
    func fetchAllTemplates() -> Promise<[TemplateDataModel]> {
        firstly { getViewContext() }
        .then { context -> Promise<[TemplateMO]> in
            guard let data = try context.fetch(TemplateMO.fetchRequest()) as? [TemplateMO] else {
                throw CoreDataError.fetchError
            }
            return .value(data)
        }
        .map { templates in templates.map { $0.toTemplateDataModel() } }
    }
    
    func save(template: TemplateDataModel) -> Promise<Void> {
        firstly { getViewContext() }
        .then { context -> Promise<Void> in
            TemplateMO.createEntity(from: template, andSaveToContext: context)
        }
        .then { self.saveContext() }
    }
    
    func update(template: TemplateDataModel) -> Promise<Void> {
        firstly { getViewContext() }
        .then { context -> Promise<Void> in
            guard let templateMO = try context.fetch(TemplateMO.fetchRequest(withId: template.id)).first else {
                throw CoreDataError.fetchError
            }
            templateMO.setup(with: template)
            return .value
        }
        .then { self.saveContext() }
    }
    
    func delete(template: TemplateDataModel) -> Promise<Void> {
        firstly { getViewContext() }
        .then { context -> Promise<Void> in
            guard let templateMO = try context.fetch(TemplateMO.fetchRequest(withId: template.id)).first else {
                throw CoreDataError.fetchError
            }
            context.delete(templateMO)
            return .value
        }
        .then { self.saveContext() }
    }
}
