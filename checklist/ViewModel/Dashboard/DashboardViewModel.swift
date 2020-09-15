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
    
    @Published var checklists: [ChecklistVO] = [] {
        didSet {
            self.objectWillChange.send()
        }
    }

    @Published var isSheetVisible = false
    @Published var isActionSheetVisible = false
    @Published var isAlertVisible = false
    
    @Published var actionSheet: DashboardActionSheet = .none {
        didSet {
            self.isActionSheetVisible = actionSheet.isActionSheedVisible
        }
    }
    @Published var alert: DashboardAlert = .none {
        didSet {
            self.isAlertVisible = alert.isVisible
        }
    }
    
    let onCreateNewChecklist = EmptySubject()
    let onSettings = EmptySubject()
    let onChecklistLongTapped = PassthroughSubject<ChecklistVO, Never>()
    let onChecklistTapped = PassthroughSubject<ChecklistVO, Never>()
    var cancellables =  Set<AnyCancellable>()
    var actionSheetView: ActionSheet { actionSheet.actionSheet }
    var alertView: Alert { alert.view }
    
    private var checklistToEdit: ChecklistVO?
    private let checklistDataSource: ChecklistDataSource
    
    init(
        checklistDataSource: ChecklistDataSource,
        templateDataSource: TemplateDataSource,
        navigationHelper: NavigationHelper
    ) {
        self.checklistDataSource = checklistDataSource
        
        checklistDataSource.checkLists.sink { [weak self] data in
            self?.handleChecklistData(data)
        }.store(in: &cancellables)
        
        checklistDataSource.selectedCheckList.dropFirst().sink { _ in
            navigationHelper.navigateToChecklistDetail(with: checklistDataSource.selectedCheckList)
        }.store(in: &cancellables)
        
        templateDataSource.templateCreated.sink { [weak self] _ in
            self?.alert = .templateCreated(gotoTemplates: {
                navigationHelper.navigateToMyTemplates(source: .dashboard)
            })
        }.store(in: &cancellables)
        
        onCreateNewChecklist.sink { [weak self] in
            self?.isSheetVisible.toggle()
        }.store(in: &cancellables)
        
        onSettings.sink {
            navigationHelper.navigateToSettings()
        }.store(in: &cancellables)
        
        onChecklistLongTapped.sink { [weak self] checklist in
            guard let self = self else { return }
            self.actionSheet = .editChecklist(
                checklist: checklist.data,
                onEdit: {
                    #warning("TODO: implement edit checklist")
                },
                onCreateTemplate: {
                    templateDataSource.createNewTemplate.send(
                        TemplateDataModel(checklist: checklist.data)
                    )
                },
                onDelete: {
                    checklistDataSource.deleteCheckList.send(checklist.data)
                }
            )
        }.store(in: &cancellables)
        
        onChecklistTapped.sink { checklist in
            checklistDataSource.selectedCheckList.send(checklist.data)
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
