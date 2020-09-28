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
}
