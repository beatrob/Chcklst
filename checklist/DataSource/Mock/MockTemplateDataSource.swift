//
//  MockTemplateDataSource.swift
//  checklist
//
//  Created by Róbert Konczi on 30/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine


class MockTemplateDataSource: TemplateDataSource {
    
    var _templates: CurrentValueSubject<[TemplateDataModel], Never> = .init(
        [
            .init(
                id: "1",
                title: "Template one",
                description: "This is my first template",
                items: [
                    .init(id: "11", name: "First things first", isDone: false, updateDate: Date()),
                    .init(id: "12", name: "Second things secons", isDone: false, updateDate: Date())
                ]
            ),
            .init(
                id: "2",
                title: "Template two",
                description: "This is my second template",
                items: [
                    .init(id: "11", name: "[2] First things first", isDone: false, updateDate: Date()),
                    .init(id: "12", name: "[2] Second things secons", isDone: false, updateDate: Date())
                ]
            ),
        ]
    )
    
    var createNewTemplate: TemplatePassthroughSubject = .init()
    
    var deleteTemplate: TemplatePassthroughSubject = .init()
    
    var templates: AnyPublisher<[TemplateDataModel], Never> {
        _templates.eraseToAnyPublisher()
    }
    
    var selectedTemplate: CurrentValueSubject<TemplateDataModel?, Never> = .init(nil)
    
    func updateItem(_ item: ChecklistItemDataModel, for template: TemplateDataModel, _ completion: @escaping (Result<Void, DataSourceError>) -> Void) {
        
    }
}
