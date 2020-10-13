//
//  DashboardViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import PromiseKit

class DashboardViewModel: ObservableObject {
    
    struct ChecklistVO {
        let id: String
        let title: String
        let counter: String
        let data: ChecklistDataModel
        let isReminderSet: Bool
        var firstUndoneItem: ChecklistItemDataModel?
    }
    
    @Published var title: String = FilterItemData.initial.title
    @Published var checklists: [ChecklistVO] = []
    @Published var alertVisibility = ViewVisibility(view: DashboardAlert.none.view)
    @Published var actionSheetVisibility = ViewVisibility(view: DashboardActionSheet.none.actionSheet)
    @Published var sheetVisibility = ViewVisibility(view: DashboardSheet.none.view)
    
    @Published var actionSheet: DashboardActionSheet = .none {
        didSet { actionSheetVisibility.set(view: actionSheet.actionSheet, isVisible: actionSheet.isActionSheedVisible) }
    }
    @Published var alert: DashboardAlert = .none {
        didSet { alertVisibility.set(view: alert.view, isVisible: alert.isVisible) }
    }
    @Published var sheet: DashboardSheet = .none {
        didSet { sheetVisibility.set(view: sheet.view, isVisible: sheet.isVisible) }
    }
    
    lazy var filterViewModel: FilterViewModel = {
        let onSelectFilter = FilterPassthroughSubject()
        onSelectFilter.sink { [weak self] filter in
            guard let self = self else { return }
            self.selectedFilter = filter
        }.store(in: &cancellables)
        return AppContext.resolver.resolve(FilterViewModel.self, argument: onSelectFilter)!
    }()
    var selectedFilter: FilterItemData = .initial {
        didSet {
            self.checklistFilter.filter = selectedFilter
            self.title = selectedFilter.title
        }
    }
    
    let onCreateNewChecklist = EmptySubject()
    let onSettings = EmptySubject()
    let onChecklistLongTapped = PassthroughSubject<ChecklistVO, Never>()
    let onChecklistTapped = PassthroughSubject<ChecklistVO, Never>()
    var cancellables =  Set<AnyCancellable>()
    
    private var checklistToEdit: ChecklistVO?
    private let checklistDataSource: ChecklistDataSource
    private let checklistFilter: ChecklistFilter
    
    init(
        checklistDataSource: ChecklistDataSource,
        templateDataSource: TemplateDataSource,
        navigationHelper: NavigationHelper,
        checklistFilter: ChecklistFilter,
        notificationManager: NotificationManager
    ) {
        self.checklistDataSource = checklistDataSource
        self.checklistFilter = checklistFilter
        
        notificationManager.deeplinkChecklistId.sink { checklistId in
            log(debug: "Did receive deepling cheklistId \(String(describing: checklistId))")
            guard let checklistId = checklistId else {
                return
            }
            guard let checklist = checklistDataSource.getChecklist(withId: checklistId) else {
                log(warning: "Checklist with id \(checklistId) not found")
                return
            }
            log(debug: "Deeplinking to checklist: \(checklist)")
            after(seconds: 1).done {
                checklistDataSource.selectedCheckList.send(checklist)
                notificationManager.clearDeeplinkcChecklistId()
            }
        }.store(in: &cancellables)
        
        checklistFilter.filteredCheckLists
            .sink { [weak self] data in
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
        
        let createChecklist = ChecklistPassthroughSubject()
        createChecklist.sink { checklist in
            checklistDataSource.createChecklist(checklist)
            .done { Logger.log.debug("Checklist created \(checklist)")}
            .catch { $0.log(message: "Create checklist failed") }
        }.store(in: &cancellables)
        
        onCreateNewChecklist.sink { [weak self] in
            self?.actionSheet = .createChecklist(
                onNewChecklist: {
                    self?.sheet = .createChecklist(
                        createNewChecklist: createChecklist,
                        createNewTemplate: templateDataSource.createNewTemplate
                    )
            },
                onNewFromTemplate: {
                    self?.sheet = .selectTemplate
            })
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
                onDelete: { [weak self] in
                    self?.alert = .confirmDeleteChecklist(onDelete: {
                        checklistDataSource.deleteChecklist(checklist.data)
                        .done { Logger.log.debug("Checklist deleted with id: \(checklist.data.id)") }
                        .catch { _ in Logger.log.error("Delete checklist failed") }
                    })
                }
            )
        }.store(in: &cancellables)
        
        onChecklistTapped.sink { checklist in
            checklistDataSource.selectedCheckList.send(checklist.data)
        }.store(in: &cancellables)
    }
    
    func handleChecklistData(_ checklists: [ChecklistDataModel]) {
        self.checklists =  checklists.map {
            ChecklistVO(
                id: $0.id,
                title: $0.title,
                counter: "\($0.items.filter(\.isDone).count)/\($0.items.count)",
                data: $0,
                isReminderSet: $0.isValidReminderSet,
                firstUndoneItem: self.getFirstUndoneItem(form: $0.items)
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
    
    func getFirstUndoneItem(form items: [ChecklistItemDataModel]) -> ChecklistItemDataModel? {
        items
            .filter(\.isUndone)
            .sorted { (left, right) -> Bool in right.updateDate > left.updateDate }
            .first
    }
}
