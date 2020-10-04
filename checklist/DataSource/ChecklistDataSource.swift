//
//  ChecklistDataSource.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import PromiseKit


protocol ChecklistDataSource {
    
    var createNewChecklist: ChecklistPassthroughSubject { get }
    var deleteCheckList: ChecklistPassthroughSubject { get }
    var checkLists: AnyPublisher<[ChecklistDataModel], Never> { get }
    var selectedCheckList: CurrentValueSubject<ChecklistDataModel?, Never> { get }
    func loadAllChecklists() -> Promise<[ChecklistDataModel]>
    func updateItem(
        _ item: ChecklistItemDataModel,
        for checkList: ChecklistDataModel,
        _ completion: @escaping (Swift.Result<Void, DataSourceError>) -> Void
    )
}


class CheckListDataSourceImpl: ChecklistDataSource {
    
    
    private var _checklists = CurrentValueSubject<[ChecklistDataModel], Never>([])
    private var cancellables =  Set<AnyCancellable>()
    
    var checkLists: AnyPublisher<[ChecklistDataModel], Never> {
        _checklists.eraseToAnyPublisher()
    }
    let selectedCheckList: CurrentValueSubject<ChecklistDataModel?, Never> = .init(nil)
    
    let createNewChecklist: ChecklistPassthroughSubject = .init()
    let deleteCheckList: ChecklistPassthroughSubject = .init()
    let coreDataManager: CoreDataChecklistManager
    
    init(coreDataManager: CoreDataChecklistManager) {
        self.coreDataManager = coreDataManager
        
        createNewChecklist.sink { checklist in
            coreDataManager.save(checklist: checklist)
            .done { self._checklists.value.append(checklist) }
            .catch { print($0.localizedDescription) }
        }.store(in: &cancellables)
        
        deleteCheckList.sink { checklist in
            coreDataManager.delete(checklist: checklist)
            .done { self._checklists.value.removeAll { $0.id == checklist.id } }
            .catch { print($0.localizedDescription) }
        }.store(in: &cancellables)
    }
    
    func updateItem(
        _ item: ChecklistItemDataModel,
        for checkList: ChecklistDataModel,
        _ completion: @escaping (Swift.Result<Void, DataSourceError>) -> Void
    ) {
        guard let index = _checklists.value.firstIndex(of: checkList) else {
            completion(.failure(.checkListNotFound))
            return
        }
        var checklist = _checklists.value[index]
        guard checklist.items.updateItem(item) else {
            return
        }
        coreDataManager.update(checklist: checklist)
        .done {
            if self._checklists.value[index].items.updateItem(item) {
                if self.selectedCheckList.value == checklist {
                    _ = self.selectedCheckList.value?.items.updateItem(item)
                }
                completion(.success(()))
            }
        }
        .catch { completion(.failure(.persitentStorageError(error: $0))) }
    }
    
    func loadAllChecklists() -> Promise<[ChecklistDataModel]>{
        coreDataManager.fetchAllChecklists()
            .get { self._checklists.value = $0 }
    }
}
