//
//  DashboardViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


class DashboardViewModel: ObservableObject {
    
    struct ChecklistVO {
        let id: String
        let title: String
        let counter: String
        let data: ChecklistDataModel
        let tag: Int
        var firstUndoneItem: ChecklistItemDataModel?
    }
    
    @Published var currentChecklistIndex: Int? {
        didSet {
            guard let index = currentChecklistIndex else {
                return
            }
            checklistDataSource.selectedCheckList.send(checklists[index].data)
        }
    }
    @Published var checklists: [ChecklistVO] = [] {
        didSet {
            self.objectWillChange.send()
        }
    }
    @Published var isCheklistDetailVisible = false
    @Published var isSheetVisible = false
    var checklistDetail: ChecklistView {
        let viewModel = ChecklistViewModel(
            checklist: self.checklistDataSource.selectedCheckList
        )
        return ChecklistView(viewModel: viewModel)
    }
    let onCreateNewChecklist = PassthroughSubject<Void, Never>()
    var cancellables =  Set<AnyCancellable>()
    
    private let checklistDataSource: ChecklistDataSource
    
    init(checklistDataSource: ChecklistDataSource) {
        self.checklistDataSource = checklistDataSource
        
        checklistDataSource.checkLists.sink { [weak self] data in
            self?.handleChecklistData(data)
        }.store(in: &cancellables)
        
        onCreateNewChecklist.sink { [weak self] in
            self?.isSheetVisible.toggle()
        }.store(in: &cancellables)
    }
    
    func handleChecklistData(_ checklists: [ChecklistDataModel]) {
        self.checklists =  checklists.enumerated().map {
            ChecklistVO(
                id: $0.element.id,
                title: $0.element.title,
                counter: "\($0.element.items.filter(\.isDone).count)/\($0.element.items.count)",
                data: $0.element,
                tag: $0.offset,
                firstUndoneItem: self.getFirstUndoneItem(form: $0.element.items)
            )
        }
    }
    
    func getItemViewModel(
        for item: ChecklistItemDataModel,
        in checkList: ChecklistVO
    ) -> ChecklistItemViewModel {
        let itemSubject = CurrentValueSubject<ChecklistItemDataModel, Never>(item)
        itemSubject.dropFirst().sink { [weak self] item in
            guard let self = self else { return }
            self.checklistDataSource.updateItem(item, for: checkList.data) { result in
                switch result {
                case .success: break
                case .failure: break
                }
            }
        }.store(in: &cancellables)
        return .init(item: itemSubject)
    }
    
    func getCreateChecklistViewModel() -> CreateChecklistViewModel {
        AppContext.resolver.resolve(CreateChecklistViewModel.self, argument: checklistDataSource.createNewChecklist)!
    }
    
    func getFirstUndoneItem(form items: [ChecklistItemDataModel]) -> ChecklistItemDataModel? {
        items
            .filter(\.isUndone)
            .sorted { (left, right) -> Bool in right.updateDate > left.updateDate }
            .first
    }
}
