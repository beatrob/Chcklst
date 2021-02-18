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
    
    @Published var title: String = FilterItemData.initial.title
    @Published var checklistCells: [DashboardChecklistCellViewModel] = []
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
    
    var selectedFilter: FilterItemData {
        didSet {
            self.checklistFilter.filter = selectedFilter
            self.title = selectedFilter.title
        }
    }
    
    let onCreateNewChecklist = EmptySubject()
    let onMenu = EmptySubject()
    var cancellables =  Set<AnyCancellable>()
    
    private var checklistToEdit: DashboardChecklistCellViewModel?
    private let checklistDataSource: ChecklistDataSource
    private let templateDataSource: TemplateDataSource
    private let checklistFilter: ChecklistFilter
    
    init(
        checklistDataSource: ChecklistDataSource,
        templateDataSource: TemplateDataSource,
        navigationHelper: NavigationHelper,
        checklistFilter: ChecklistFilter,
        notificationManager: NotificationManager
    ) {
        self.checklistDataSource = checklistDataSource
        self.templateDataSource = templateDataSource
        self.checklistFilter = checklistFilter
        self.selectedFilter = .initial
        
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
        
        checklistDataSource.selectedCheckList.dropFirst().sink { checklist in
            guard let checklist = checklist else {
                return
            }
            navigationHelper.navigateToChecklistDetail(with: checklist)
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
                    self?.sheet = .createChecklist
                },
                onNewFromTemplate: {
                    self?.sheet = .selectTemplate
            })
        }.store(in: &cancellables)
        
        onMenu.sink { [weak self] in
            self?.sheet = .menu
        }.store(in: &cancellables)
        
        self.checklistFilter.filter = .initial
        self.title = selectedFilter.title
    }
    
    func handleChecklistData(_ checklists: [ChecklistDataModel]) {
        if checklistCells.isEmpty {
            checklistCells = checklists.map {
                self.getChecklistCellViewModel(with: $0)
            }
            return
        } else {
            // update/insert
            checklists.forEach { checklist in
                if let cell = self.checklistCells.first(where: { $0.id == checklist.id }) {
                    cell.update(with: checklist)
                } else {
                    self.checklistCells.insert(getChecklistCellViewModel(with: checklist), at: 0)
                }
            }
            // delete
        }
    }
    
    func getChecklistCellViewModel(with checklist: ChecklistDataModel) -> DashboardChecklistCellViewModel {
        let viewModel = DashboardChecklistCellViewModel(checklist: checklist)
        viewModel.onTapped.sink { [weak self] checklist in
            self?.checklistDataSource.selectedCheckList.send(checklist)
        }.store(in: &cancellables)
        viewModel.onLongTapped.sink { [weak self] checklist in
            guard let self = self else { return }
            self.actionSheet = .editChecklist(
                checklist: checklist,
                onEdit: {
                    #warning("TODO: implement edit checklist")
                },
                onCreateTemplate: {
                    self.templateDataSource.createTemplate(.init(checklist: checklist))
                        .catch { $0.log(message: "Failed to create new template from checklist \(checklist)") }
                },
                onDelete: { [weak self] in
                    self?.alert = .confirmDeleteChecklist(onDelete: {
                        self?.checklistDataSource.deleteChecklist(checklist)
                        .done { Logger.log.debug("Checklist deleted with id: \(checklist.id)") }
                        .catch { _ in Logger.log.error("Delete checklist failed") }
                    })
                }
            )
        }.store(in: &cancellables)
        viewModel.onUpdateItem.sink { [weak self] item in
            guard let self = self else { return }
            self.checklistDataSource.updateItem(item, in: checklist)
                .catch {
                    $0.log(message: "Failed to update item \(item)")
                }
        }.store(in: &cancellables)
        return viewModel
    }
}
