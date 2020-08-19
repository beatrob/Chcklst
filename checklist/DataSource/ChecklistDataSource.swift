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
    
    var createNewChecklist: CreateChecklistSubject { get }
    var checkLists: AnyPublisher<[ChecklistDataModel], Never> { get }
    var selectedCheckList: CurrentValueSubject<ChecklistDataModel?, Never> { get }
    func updateItem(
        _ item: ChecklistItemDataModel,
        for checkList: ChecklistDataModel,
        _ completion: @escaping (Result<Void, DataSourceError>) -> Void
    )
}


class CheckListDataSourceImpl: ChecklistDataSource {
    
    var checkLists: AnyPublisher<[ChecklistDataModel], Never> {
        AnyPublisher(Empty())
    }
    
    let selectedCheckList: CurrentValueSubject<ChecklistDataModel?, Never> = .init(nil)
    
    let createNewChecklist: CreateChecklistSubject = .init()
    
    func updateItem(
        _ item: ChecklistItemDataModel,
        for checkList: ChecklistDataModel,
        _ completion: @escaping (Result<Void, DataSourceError>) -> Void
    ) { }
}
