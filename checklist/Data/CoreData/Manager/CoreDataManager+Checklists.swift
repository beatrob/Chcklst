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


extension CoreDataManagerImpl: CoreDataChecklistManager {
    
    func fetchAllChecklists() -> Promise<[ChecklistDataModel]> {
        firstly { getViewContext() }
        .then { context -> Promise<[ChecklistMO]> in
            let data = try context.fetch(ChecklistMO.fetchRequest())
            return .value(data)
        }
        .map { checklists in checklists.map { $0.toChecklistDataModel() } }
    }
    
    func fetch(checklist: ChecklistDataModel) -> Promise<ChecklistDataModel> {
        firstly { getViewContext() }
        .then { context -> Promise<[ChecklistMO]> in
            let data = try context.fetch(ChecklistMO.fetchRequest(withId: checklist.id))
            return .value(data)
        }
        .map { checklists in checklists.map { $0.toChecklistDataModel() }.first! }
    }
    
    func save(checklist: ChecklistDataModel) -> Promise<Void> {
        firstly { getViewContext() }
        .then { context -> Promise<Void> in
            ChecklistMO.createEntity(from: checklist, andSaveToContext: context)
        }
        .then { self.saveContext() }
    }
    
    func update(checklist: ChecklistDataModel) -> Promise<Void> {
        firstly { getViewContext() }
        .then { context -> Promise<Void> in
            guard let checklistMO = try context.fetch(ChecklistMO.fetchRequest(withId: checklist.id)).first else {
                throw CoreDataError.fetchError
            }
            checklistMO.setup(with: checklist, context: context)
            return .value
        }
        .then { self.saveContext() }
    }
    
    func updateReminderDate(_ date: Date?, forChecklistWithId id: String) -> Promise<ChecklistDataModel> {
        firstly {
            getViewContext()
        }.then { context -> Promise<ChecklistMO> in
            guard let checklistMO = try context.fetch(ChecklistMO.fetchRequest(withId: id)).first else {
                throw CoreDataError.fetchError
            }
            checklistMO.reminderDate = date
            checklistMO.updateDate = Date()
            return .value(checklistMO)
        }.map {
            $0.toChecklistDataModel()
        }.then { checklist in
            self.saveContext().map { checklist }
        }
    }
    
    func delete(checklist: ChecklistDataModel) -> Promise<Void> {
        firstly { getViewContext() }
        .then { context -> Promise<Void> in
            guard let checklistMO = try context.fetch(ChecklistMO.fetchRequest(withId: checklist.id)).first else {
                throw CoreDataError.fetchError
            }
            (checklistMO.items as! Set<ItemMO>).forEach { context.delete($0) }
            context.delete(checklistMO)
            return .value
        }
        .then { self.saveContext() }
    }
}
