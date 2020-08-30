//
//  TemplateDataSource.swift
//  checklist
//
//  Created by Róbert Konczi on 30/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine


protocol TemplateDataSource {
    
    var createNewTemplate: TemplatePassthroughSubject { get }
    var deleteTemplate: TemplatePassthroughSubject { get }
    var templates: AnyPublisher<[TemplateDataModel], Never> { get }
    var selectedTemplate: TemplateCurrentValueSubject { get }
    func updateItem(
        _ item: ChecklistItemDataModel,
        for template: TemplateDataModel,
        _ completion: @escaping (Result<Void, DataSourceError>) -> Void
    )
}


class TemplateDataSourceImpl: TemplateDataSource {
    
    var createNewTemplate: TemplatePassthroughSubject = .init()
    
    var deleteTemplate: TemplatePassthroughSubject = .init()
    
    var templates: AnyPublisher<[TemplateDataModel], Never> = AnyPublisher(Empty())
    
    var selectedTemplate: CurrentValueSubject<TemplateDataModel?, Never> = .init(nil)
    
    func updateItem(_ item: ChecklistItemDataModel, for template: TemplateDataModel, _ completion: @escaping (Result<Void, DataSourceError>) -> Void) {
        
    }
}
