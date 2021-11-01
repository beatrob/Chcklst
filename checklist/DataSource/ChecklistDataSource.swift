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
    func updateItem(_ item: ItemDataModel, in checkList: ChecklistDataModel) -> Promise<ChecklistDataModel>
    func updateItem(_ item: ItemDataModel, isDone: Bool) -> Promise<Void>
    func getChecklist(withId id: String) -> ChecklistDataModel?
    func createChecklist(_ checklist: ChecklistDataModel) -> Promise<ChecklistDataModel>
    func deleteChecklist(_ checklist: ChecklistDataModel) -> Promise<Void>
    func updateChecklist(_ checklist: ChecklistDataModel) -> Promise<Void>
    func updateReminderDate(_ date: Date?, for checklist: ChecklistDataModel) -> Promise<Void>
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
    
    func updateItem(_ item: ItemDataModel,in checkList: ChecklistDataModel) -> Promise<ChecklistDataModel> {
        guard let index = _checklists.value.firstIndex(of: checkList) else {
            return .init(error: DataSourceError.checkListNotFound)
        }
        var checklist = _checklists.value[index]
        guard checklist.items.updateItem(item) else {
            return .init(error: DataSourceError.itemNotFound)
        }
        checklist.updateToCurrentDate()
        return coreDataManager.update(checklist: checklist)
        .get {
            self._checklists.value[index].items.updateItem(item)
        }.map { checklist }
    }
    
    func updateItem(_ item: ItemDataModel, isDone: Bool) -> Promise<Void> {
        guard let checklist = _checklists.value.first(where: { $0.items.contains(item) }) else {
            return .init(error: DataSourceError.checkListNotFound)
        }
        var i = item
        i.updateDate = Date()
        i.isDone = isDone
        return updateItem(i, in: checklist).asVoid()
    }
    
    func updateReminderDate(_ date: Date?, for checklist: ChecklistDataModel) -> Promise<Void> {
        guard let index = _checklists.value.firstIndex(of: checklist) else {
            return .init(error: DataSourceError.checkListNotFound)
        }
        return firstly {
            coreDataManager.updateReminderDate(date, forChecklistWithId: checklist.id)
        }.get {
            self._checklists.value[index].reminderDate = date
        }
    }
    
    func loadAllChecklists() -> Promise<[ChecklistDataModel]>{
        coreDataManager.fetchAllChecklists()
            .get { self._checklists.value = $0 }
    }
    
    func getChecklist(withId id: String) -> ChecklistDataModel? {
        _checklists.value.first { $0.id == id }
    }
    
    func createChecklist(_ checklist: ChecklistDataModel) -> Promise<ChecklistDataModel> {
        coreDataManager
            .save(checklist: checklist)
            .get { self._checklists.value.append(checklist) }
            .map { checklist }
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
        var toUpdate = _checklists.value.filter { $0.hasExpiredReminder }
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
    
    func deleteExpiredNotification(for checklistId: String) -> Promise<Void> {
        guard
            var checklist = _checklists.value.first(where: { $0.id == checklistId }),
            checklist.hasExpiredReminder
        else {
            return .init(error: DataSourceError.checkListNotFound)
        }
        checklist.removeReminderDate()
        return updateChecklist(checklist)
    }
}
