//
//  MockCoreDataManager.swift
//  checklist
//
//  Created by Róbert Konczi on 28/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import PromiseKit


class MockCoreDataManager: CoreDataManager {
    
    func initialize() -> Promise<Void> { .value }
}
