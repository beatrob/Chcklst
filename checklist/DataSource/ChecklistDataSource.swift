//
//  ChecklistDataSource.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import PromiseKit


protocol ChecklistDataSource {
    
    func getActiveChecklists() -> Promise<[ChecklistDataModel]>
}


class CheckListDataSourceImpl: ChecklistDataSource {
    
    func getActiveChecklists() -> Promise<[ChecklistDataModel]> {
        .value([])
    }
}
