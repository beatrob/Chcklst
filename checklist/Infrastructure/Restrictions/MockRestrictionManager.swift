//
//  MockRestrictionManager.swift
//  checklist
//
//  Created by Robert Konczi on 6/27/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import PromiseKit

class MockRestrictionManager: RestrictionManager {
    
    let restrictionsEnabled: Bool = true
    
    func verifyCreateChecklist() -> Promise<Bool> {
        .value(true)
    }
    
    func verifyCreateTemplate() -> Promise<Bool> {
        .value(true)
    }
    
    func verifyCreateSchedule() -> Promise<Bool> {
        .value(true)
    }
    
    func verifyCreateChecklist(presenter: RestrictionPresenter) -> Promise<Bool> {
        .value(true)
    }
    
    func verifyCreateTemplate(presenter: RestrictionPresenter) -> Promise<Bool> {
        .value(true)
    }
    
    func verifyCreateSchedule(presenter: RestrictionPresenter) -> Promise<Bool> {
        .value(true)
    }
}
