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
    func loadAllChecklists() -> Promise<[ChecklistDataModel]>
    func reloadChecklist(_ checklist: ChecklistDataModel) -> Promise<ChecklistDataModel>
    func getChecklist(withId id: String) -> ChecklistDataModel?
    func createChecklist(_ checklist: ChecklistDataModel) -> Promise<Void>
    func deleteChecklist(_ checklist: ChecklistDataModel) -> Promise<Void>
    func updateChecklist(_ checklist: ChecklistDataModel) -> Promise<Void>
    func updateReminderDate(_ date: Date?, for checklist: ChecklistDataModel) -> Promise<ChecklistDataModel>
    func deleteExpiredNotificationDates() -> Promise<Void>
    func deleteExpiredNotification(for checklistId: String) -> Promise<Void>
}


class CheckListDataSourceImpl: ChecklistDataSource {
    
    
    private var _checklists = CurrentValueSubject<[ChecklistDataModel], Never>([])
    private var cancellables =  Set<AnyCancellable>()
    
    var checkLists: AnyPublisher<[ChecklistDataModel], Never> {
        _checklists.eraseToAnyPublisher()
    }
    
    let coreDataManager: CoreDataChecklistManager
    
    init(coreDataManager: CoreDataChecklistManager) {
        self.coreDataManager = coreDataManager
    }
    
    func updateReminderDate(_ date: Date?, for checklist: ChecklistDataModel) -> Promise<ChecklistDataModel> {
        guard let index = _checklists.value.firstIndex(of: checklist) else {
            return .init(error: DataSourceError.checkListNotFound)
        }
        return firstly {
            coreDataManager.updateReminderDate(date, forChecklistWithId: checklist.id)
        }.get {
            self._checklists.value[index] = $0
        }
    }
    
    func loadAllChecklists() -> Promise<[ChecklistDataModel]>{
        coreDataManager.fetchAllChecklists()
            .get { self._checklists.value = $0 }
    }
    
    func reloadChecklist(_ checklist: ChecklistDataModel) -> Promise<ChecklistDataModel> {
        coreDataManager.fetch(checklist: checklist)
            .get { ch in
                var checklists = self._checklists.value
                guard let i = checklists.firstIndex(of: checklist) else {
                    throw DataSourceError.checkListNotFound
                }
                checklists.remove(at: i)
                checklists.insert(ch, at: i)
                self._checklists.value = checklists
            }
    }
    
    func getChecklist(withId id: String) -> ChecklistDataModel? {
        _checklists.value.first { $0.id == id }
    }
    
    func createChecklist(_ checklist: ChecklistDataModel) -> Promise<Void> {
        coreDataManager
            .save(checklist: checklist)
            .get { self._checklists.value.append(checklist) }
    }
    
    func deleteChecklist(_ checklist: ChecklistDataModel) -> Promise<Void> {
        coreDataManager.delete(checklist: checklist)
        .get { self._checklists.value.removeAll { $0.id == checklist.id } }
    }
    
    func updateChecklist(_ checklist: ChecklistDataModel) -> Promise<Void> {
        coreDataManager.update(checklist: checklist)
        .get {
            if !self._checklists.value.update(checklist) {
                throw DataSourceError.checklistUpdateInMemoryFailed
            }
        }
    }
    
    func deleteExpiredNotificationDates() -> Promise<Void> {
        let toUpdate = _checklists.value.filter { $0.hasExpiredReminder }
        guard !toUpdate.isEmpty else {
            return .value
        }
        return when(
            resolved: toUpdate.map { ch in
                coreDataManager.updateReminderDate(nil, forChecklistWithId: ch.id).get {
                    if !self._checklists.value.update($0) {
                        throw DataSourceError.checklistUpdateInMemoryFailed
                    }
                }
            }
        ).asVoid()
    }
    
    func deleteExpiredNotification(for checklistId: String) -> Promise<Void> {
        guard
            let checklist = _checklists.value.first(where: { $0.id == checklistId }),
            checklist.hasExpiredReminder
        else {
            return .init(error: DataSourceError.checkListNotFound)
        }
        return coreDataManager.updateReminderDate(nil, forChecklistWithId: checklist.id).get {
            if !self._checklists.value.update($0) {
                throw DataSourceError.checklistUpdateInMemoryFailed
            }
        }.asVoid()
    }
}
