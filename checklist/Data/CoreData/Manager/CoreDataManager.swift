//
//  CoreDataManager.swift
//  checklist
//
//  Created by Róbert Konczi on 28/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import PromiseKit

protocol CoreDataManager {
    
    func initialize() -> Promise<Void>
}

protocol CoreDataChecklistManager {
    
    func fetchAllChecklists() -> Promise<[ChecklistDataModel]>
    func save(checklist: ChecklistDataModel) -> Promise<Void>
    func update(checklist: ChecklistDataModel) ->  Promise<Void>
    func updateReminderDate(_ date: Date?, forChecklistWithId id: String) -> Promise<Void>
    func delete(checklist: ChecklistDataModel) -> Promise<Void>
}

protocol CoreDataTemplateManager {
    
    func fetchAllTemplates() -> Promise<[TemplateDataModel]>
    func save(template: TemplateDataModel) -> Promise<Void>
    func update(template: TemplateDataModel) ->  Promise<Void>
    func delete(template: TemplateDataModel) -> Promise<Void>
}
