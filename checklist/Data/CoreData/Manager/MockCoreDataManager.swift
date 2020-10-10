//
//  MockCoreDataManager.swift
//  checklist
//
//  Created by Róbert Konczi on 28/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import PromiseKit


class MockCoreDataManager: CoreDataManager, CoreDataChecklistManager {
    
    func fetchAllChecklists() -> Promise<[ChecklistDataModel]> { .value([]) }
    
    func save(checklist: ChecklistDataModel) -> Promise<Void> { .value }
    
    func update(checklist: ChecklistDataModel) -> Promise<Void> { .value }
    
    func delete(checklist: ChecklistDataModel) -> Promise<Void> { .value }
    
    func initialize() -> Promise<Void> { .value }
}
