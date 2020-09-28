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


extension CoreDataManagerImpl {
    
    func fetchAllChecklists() -> Promise<[ChecklistDataModel]> {
        firstly { getViewContext() }
        .then { context -> Promise<[ChecklistMO]> in
            guard let data = try context.fetch(ChecklistMO.fetchRequest()) as? [ChecklistMO] else {
                throw CoreDataError.failedToFetch
            }
            return .value(data)
        }
        .map { checklists in checklists.map { $0.toChecklistDataModel() } }
    }
}
