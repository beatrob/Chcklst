//
//  MockTemplateDataSource.swift
//  checklist
//
//  Created by Róbert Konczi on 30/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import PromiseKit


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
    
    var updateTemplate: TemplatePassthroughSubject = .init()
    
    var deleteTemplate: TemplatePassthroughSubject = .init()
    
    var templateCreated: AnyPublisher<TemplateDataModel, Never> {
        _templateCreated.eraseToAnyPublisher()
    }
    
    var templates: AnyPublisher<[TemplateDataModel], Never> {
        _templates.eraseToAnyPublisher()
    }
    
    var selectedTemplate: CurrentValueSubject<TemplateDataModel?, Never> = .init(nil)
    
    var cancellables =  Set<AnyCancellable>()
    
    private let _templateCreated: TemplatePassthroughSubject = .init()
    
    init() {
        deleteTemplate.sink { [weak self] template in
            self?._templates.value.removeAll { $0.id == template.id }
        }.store(in: &cancellables)
        
        updateTemplate.sink { [weak self] template in
            guard let self = self else { return }
            if let index = self._templates.value.firstIndex(where: { $0 == template }) {
                self._templates.value[index] = template
            }
        }.store(in: &cancellables)
    }
    
    func updateItem(_ item: ChecklistItemDataModel, for template: TemplateDataModel, _ completion: @escaping (Swift.Result<Void, DataSourceError>) -> Void) {
        
    }
    
    func loadAllTemplates() -> Promise<[TemplateDataModel]> {
        .value(_templates.value)
    }
    
    func createTemplate(_ template: TemplateDataModel) -> Promise<Void> {
        _templates.value.insert(template, at: 0)
        _templateCreated.send(template)
        return .value
    }
}
