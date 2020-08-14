//
//  ChecklistDataSource.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine


protocol ChecklistDataSource {
    
    var checkLists: AnyPublisher<[ChecklistDataModel], Never> { get }
    var selectedCheckList: AnyPublisher<ChecklistDataModel, Never> { get }
}


class CheckListDataSourceImpl: ChecklistDataSource {
    
    var checkLists: AnyPublisher<[ChecklistDataModel], Never> {
        AnyPublisher(Empty())
    }
    
    var selectedCheckList: AnyPublisher<ChecklistDataModel, Never> {
        AnyPublisher(Empty())
    }
}
