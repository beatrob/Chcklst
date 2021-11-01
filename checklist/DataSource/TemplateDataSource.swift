//
//  TemplateDataSource.swift
//  checklist
//
//  Created by Róbert Konczi on 30/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import PromiseKit


protocol TemplateDataSource {
    
    var templates: AnyPublisher<[TemplateDataModel], Never> { get }
    var selectedTemplate: TemplateCurrentValueSubject { get }
    func loadAllTemplates() -> Promise<[TemplateDataModel]>
    func updateItem(
        _ item: ItemDataModel,
        for template: TemplateDataModel,
        _ completion: @escaping (Swift.Result<Void, DataSourceError>) -> Void
    )
    func createTemplate(_ template: TemplateDataModel) -> Promise<Void>
    func updateTemplate(_ template: TemplateDataModel) -> Promise<Void>
    func deleteTemplate(_ template: TemplateDataModel) -> Promise<Void>
}


class TemplateDataSourceImpl: TemplateDataSource {
    
    let coreDataManager: CoreDataTemplateManager
    
    var _templates = CurrentValueSubject<[TemplateDataModel], Never>([])
    var templates: AnyPublisher<[TemplateDataModel], Never> {
        _templates.eraseToAnyPublisher()
    }
    
    var selectedTemplate: CurrentValueSubject<TemplateDataModel?, Never> = .init(nil)
    
    private var cancellables =  Set<AnyCancellable>()
    
    init(coreDataManager: CoreDataTemplateManager) {
        self.coreDataManager = coreDataManager
    }
    
    func updateItem(_ item: ItemDataModel, for template: TemplateDataModel, _ completion: @escaping (Swift.Result<Void, DataSourceError>) -> Void) {
        guard let index = _templates.value.firstIndex(of: template) else {
            completion(.failure(.templateNotFound))
            return
        }
        var template = _templates.value[index]
        guard template.items.updateItem(item) else {
            return
        }
        coreDataManager.update(template: template)
        .done {
            if self._templates.value[index].items.updateItem(item) {
                completion(.success(()))
            }
        }
        .catch { completion(.failure(.persitentStorageError(error: $0))) }
    }
    
    func loadAllTemplates() -> Promise<[TemplateDataModel]> {
        coreDataManager.fetchAllTemplates()
        .get { self._templates.value = $0 }
    }
    
    func createTemplate(_ template: TemplateDataModel) -> Promise<Void> {
        coreDataManager.save(template: template)
        .get {
            self._templates.value.append(template)
        }
    }
    
    func deleteTemplate(_ template: TemplateDataModel) -> Promise<Void> {
        firstly {
            coreDataManager.delete(template: template)
        }.get {
            let index = try self.getIndex(of: template)
            self._templates.value.remove(at: index)
        }
    }
    
    func updateTemplate(_ template: TemplateDataModel) -> Promise<Void> {
        firstly {
            coreDataManager.update(template: template)
        }.get {
            let index = try self.getIndex(of: template)
            self._templates.value[index] = template
        }
    }
}


private extension TemplateDataSourceImpl {
    
    func getIndex(of template: TemplateDataModel) throws -> Int {
        guard let index = _templates.value.firstIndex(of: template) else {
            throw DataSourceError.templateNotFound
        }
        return index
    }
}
