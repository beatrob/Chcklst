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
    
    var checkLists: AnyPublisher<[ChecklistDataModel], Never> { get }
    var selectedCheckList: CurrentValueSubject<ChecklistDataModel?, Never> { get }
    func loadAllChecklists() -> Promise<[ChecklistDataModel]>
    func updateItem(
        _ item: ChecklistItemDataModel,
        for checkList: ChecklistDataModel,
        _ completion: @escaping (Swift.Result<Void, DataSourceError>) -> Void
    )
    func getChecklist(withId id: String) -> ChecklistDataModel?
    func createChecklist(_ checklist: ChecklistDataModel) -> Promise<Void>
    func deleteChecklist(_ checklist: ChecklistDataModel) -> Promise<Void>
    func updateChecklist(_ checklist: ChecklistDataModel) -> Promise<Void>
    func deleteExpiredNotificationDates() -> Promise<Void>
}


class CheckListDataSourceImpl: ChecklistDataSource {
    
    
    private var _checklists = CurrentValueSubject<[ChecklistDataModel], Never>([])
    private var cancellables =  Set<AnyCancellable>()
    
    var checkLists: AnyPublisher<[ChecklistDataModel], Never> {
        _checklists.eraseToAnyPublisher()
    }
    let selectedCheckList: CurrentValueSubject<ChecklistDataModel?, Never> = .init(nil)
    
    let coreDataManager: CoreDataChecklistManager
    
    init(coreDataManager: CoreDataChecklistManager) {
        self.coreDataManager = coreDataManager
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
    
    func getChecklist(withId id: String) -> ChecklistDataModel? {
        _checklists.value.first { $0.id == id }
    }
    
    func createChecklist(_ checklist: ChecklistDataModel) -> Promise<Void> {
        coreDataManager.save(checklist: checklist)
        .get { self._checklists.value.append(checklist) }
    }
    
    func deleteChecklist(_ checklist: ChecklistDataModel) -> Promise<Void> {
        coreDataManager.delete(checklist: checklist)
        .get { self._checklists.value.removeAll { $0.id == checklist.id } }
    }
    
    func updateChecklist(_ checklist: ChecklistDataModel) -> Promise<Void> {
        coreDataManager.update(checklist: checklist)
        .get {
            if !self._checklists.value.updateItem(checklist) {
                throw DataSourceError.checklistUpdateInMemoryFailed
            }
        }
    }
    
    func deleteExpiredNotificationDates() -> Promise<Void> {
        let now =  Date()
        var toUpdate = _checklists.value.filter {
            if let reminder = $0.reminderDate, reminder <= now {
                return true
            }
            return false
        }
        guard !toUpdate.isEmpty else {
            return .value
        }
        for i in 0 ..< toUpdate.count {
            toUpdate[i].removeReminderDate()
        }
        return when(
            resolved: toUpdate.map {
                updateChecklist($0)
            }
        ).asVoid()
    }
}
