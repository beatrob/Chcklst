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
import SwiftUI

class DashboardViewModel: ObservableObject {
    
    @Published var checklistCells: [DashboardChecklistCellViewModel] = [] {
        didSet {
            if checklistCells.isEmpty {
                isNoSearchResultsVisible = checklistFilterAndSort.isSearching
                isNoFilterResulrsVisible = checklistFilterAndSort.isFiltering
                isEmptyListViewVisible = !isNoSearchResultsVisible && !isNoFilterResulrsVisible
            } else {
                isNoSearchResultsVisible = false
                isEmptyListViewVisible = false
                isNoFilterResulrsVisible = false
            }
        }
    }
    @Published var alertVisibility = ViewVisibility(view: DashboardAlert.none.view)
    @Published var actionSheetVisibility = ViewVisibility(view: DashboardActionSheet.none.actionSheet)
    @Published var isSidemenuVisible = false
    @Published var isSheetVisible = false
    @Published var isEmptyListViewVisible = false
    @Published var isNoSearchResultsVisible = false
    @Published var isNoFilterResulrsVisible = false
    
    @Published var actionSheet: DashboardActionSheet = .none {
        didSet { actionSheetVisibility.set(view: actionSheet.actionSheet, isVisible: actionSheet.isActionSheedVisible) }
    }
    @Published var alert: DashboardAlert = .none {
        didSet { alertVisibility.set(view: alert.view, isVisible: alert.isVisible) }
    }
    @Published var sheet: DashboardSheet = .none {
        didSet {
            isSheetVisible = sheet.isVisible
            sheetView = sheet.view
        }
    }
    
    let onCreateNewChecklist = EmptySubject()
    let onClearFilter = EmptySubject()
    let onMenu = EmptySubject()
    let onDarkOverlayTapped = EmptySubject()
    let navBarViewModel = AppContext.resolver.resolve(DashboardNavBarViewModel.self)!
    let menuViewModel = AppContext.resolver.resolve(MenuViewModel.self)!
    
    var cancellables =  Set<AnyCancellable>()
    var sheetView = AnyView.empty
    
    private lazy var selectTemplateVM: SelectTemplateViewModel = {
        AppContext.resolver.resolve(SelectTemplateViewModel.self)!
    }()
    private var checklistToEdit: DashboardChecklistCellViewModel?
    private let checklistDataSource: ChecklistDataSource
    private let templateDataSource: TemplateDataSource
    private let scheduleDataSource: ScheduleDataSource
    private let notificationManager: NotificationManager
    private let checklistFilterAndSort: ChecklistFilterAndSort
    private let navigationHelper: NavigationHelper
    private let createScheduleSubject = EmptySubject()
    private let createScheduleViewModel: CreateScheduleViewModel
    
    init(
        checklistDataSource: ChecklistDataSource,
        templateDataSource: TemplateDataSource,
        scheduleDataSource: ScheduleDataSource,
        navigationHelper: NavigationHelper,
        checklistFilterAndSort: ChecklistFilterAndSort,
        notificationManager: NotificationManager
    ) {
        self.checklistDataSource = checklistDataSource
        self.templateDataSource = templateDataSource
        self.checklistFilterAndSort = checklistFilterAndSort
        self.scheduleDataSource = scheduleDataSource
        self.notificationManager = notificationManager
        self.navigationHelper = navigationHelper
        self.createScheduleViewModel = AppContext.resolver.resolve(
            CreateScheduleViewModel.self,
            argument: createScheduleSubject.eraseToAnyPublisher()
        )!
        
        setupCreateScheduleHandling()
        
        notificationManager.deeplinkChecklistId.sink { checklistId in
            log(debug: "Did receive deepling cheklistId \(checklistId)")
            guard !checklistId.isEmpty else {
                return
            }
            guard let checklist = checklistDataSource.getChecklist(withId: checklistId) else {
                log(warning: "Checklist with id \(checklistId) not found")
                return
            }
            log(debug: "Deeplinking to checklist: \(checklist)")
            after(seconds: 1).done {
                navigationHelper.navigateToChecklistDetail(with: checklist, shouldEdit: false)
                notificationManager.clearDeeplinkcChecklistId()
            }
        }.store(in: &cancellables)
        
        notificationManager.deeplinkScheduleId.sink { [weak self] scheduleId in
            guard !scheduleId.isEmpty else {
                return
            }
            self?.createChecklist(for: scheduleId, openAfterCreated: false)
        }.store(in: &cancellables)
        
        checklistFilterAndSort.filteredAndSortedCheckLists
            .sink { [weak self] data in
            self?.handleChecklistData(data)
        }.store(in: &cancellables)
        
        checklistFilterAndSort.searchResults.sink { [weak self] results in
            guard let self = self else {
                return
            }
            self.checklistCells = results.map {
                self.getChecklistCellViewModel(with: $0)
            }
        }.store(in: &cancellables)
        
        let createChecklist = ChecklistPassthroughSubject()
        createChecklist.sink { checklist in
            checklistDataSource.createChecklist(checklist)
            .done { _ in Logger.log.debug("Checklist created \(checklist)")}
            .catch { $0.log(message: "Create checklist failed") }
        }.store(in: &cancellables)
        
        onCreateNewChecklist.sink { [weak self] in
            guard let self = self else {
                return
            }
            self.actionSheet = .createChecklist(
                onNewChecklist: {
                    self.showCreateNewChecklist()
                },
                onNewFromTemplate: {
                    let viewModel = self.selectTemplateVM
                    viewModel.title = "Create Checklist"
                    viewModel.descriptionText = "Select a Template to create a new Checklist"
                    self.sheet = .selectTemplate(viewModel: viewModel)
                },
                onCreateSchedule: self.createScheduleSubject
            )
        }.store(in: &cancellables)
        
        onMenu.sink { [weak self] in
            self?.sheet = .menu
        }.store(in: &cancellables)
        
        navBarViewModel.onMenuTapped.sink { [weak self] _ in
            self?.toggleSidemenu()
        }.store(in: &cancellables)
        
        navBarViewModel.search.sink { searchText in
            checklistFilterAndSort.search = searchText
        }.store(in: &cancellables)
        
        navBarViewModel.onAddTapped.subscribe(onCreateNewChecklist).store(in: &cancellables)
        
        menuViewModel.onSelectSort.sink { [weak self] sort in
            self?.checklistCells.removeAll()
            self?.navBarViewModel.sortedByTitle = sort.title
            self?.checklistFilterAndSort.sort = sort
            self?.closeSideMenu()
        }.store(in: &cancellables)
        
        
        menuViewModel.onSelectFilter
            .merge(with: onClearFilter.map { FilterDataModel.none })
            .sink { [weak self] filter in
                self?.checklistCells.removeAll()
                self?.navBarViewModel.filterTitle = filter.title
                self?.navBarViewModel.isFilterVisible = filter.isVisibleInNavbar
                self?.checklistFilterAndSort.filter = filter
                self?.closeSideMenu()
            }
            .store(in: &cancellables)
        
        menuViewModel.onSelectMyTemplates.sink { [weak self] _ in
            navigationHelper.navigateToMyTemplates(source: .dashboard)
            self?.toggleSidemenu()
        }.store(in: &cancellables)
        
        menuViewModel.onSelectSettings.sink { [weak self] _ in
            navigationHelper.navigateToSettings()
            self?.toggleSidemenu()
        }.store(in: &cancellables)
        
        menuViewModel.onSelectSchedules.sink { [weak self] _ in
            navigationHelper.navigateToSchedules()
            self?.toggleSidemenu()
        }.store(in: &cancellables)
        
        menuViewModel.onSelectAbout.sink { [weak self] in
            navigationHelper.navigateToAbout()
            self?.toggleSidemenu()
        }.store(in: &cancellables)
        
        onDarkOverlayTapped.sink { [weak self] in
            self?.toggleSidemenu()
        }.store(in: &cancellables)
        
        checklistFilterAndSort.sort = .initial
        loadPendingSchedules()
        
        AppContext.didEnterForeground.delay(for: .seconds(1), scheduler: RunLoop.main).sink { [weak self] in
            self?.loadPendingSchedules()
        }.store(in: &cancellables)
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
            if checklists.count < self.checklistCells.count {
                let toDelete = self.checklistCells.enumerated().filter {
                    !checklists.contains($0.element.checklist)
                }
                toDelete.map { $0.offset }.forEach {
                    self.checklistCells.remove(at: $0)
                }
            }
        }
    }
    
    func getChecklistCellViewModel(with checklist: ChecklistDataModel) -> DashboardChecklistCellViewModel {
        let viewModel = DashboardChecklistCellViewModel(checklist: checklist)
        
        viewModel.onChecklistTapped.sink { [weak self] checklist in
            self?.navigationHelper.navigateToChecklistDetail(with: checklist, shouldEdit: false)
        }.store(in: &cancellables)
        
        viewModel.onChecklistLongTapped.sink { [weak self] checklist in
            guard let self = self else { return }
            self.actionSheet = .editChecklist(checklist: checklist, delegate: self)
            Haptics.play(.actionSheet)
        }.store(in: &cancellables)
        
        viewModel.onDeleteCheklistTapped.sink { [unowned self] checklist in
            self.handleDeleteChecklist(checklist)
        }.store(in: &cancellables)
        
        viewModel.onUpdateItem.sink { [weak self] item in
            guard let self = self else { return }
            self.checklistDataSource.updateItem(item, in: checklist)
                .done { viewModel.update(with: $0) }
                .catch {
                    $0.log(message: "Failed to update item \(item)")
                }
        }.store(in: &cancellables)
        
        return viewModel
    }
}


// MARK: - Private methods

private extension DashboardViewModel {
    
    func toggleSidemenu() {
        withAnimation(.easeOut(duration: 0.2)) {
            self.isSidemenuVisible.toggle()
        }
    }
    
    func closeSideMenu() {
        if isSidemenuVisible {
            toggleSidemenu()
        }
    }
    
    func showCreateNewChecklist() {
        let viewModel = AppContext.resolver.resolve(
            ChecklistViewModel.self,
            argument:ChecklistViewState.createNew
        )!
        viewModel.onDidCreateTemplate.sink { [weak self] in
            self?.alert = .templateCreated(
                gotoTemplates: { self?.navigationHelper.navigateToMyTemplates(source: .dashboard) }
            )
        }.store(in: &self.cancellables)
        self.sheet = .createChecklist(viewModel: viewModel)
    }
    
    func setupCreateScheduleHandling() {
        createScheduleViewModel.didCreateSchedulePublisher.sink { [weak self] in
            self?.sheetView = .empty
            self?.isSheetVisible = false
            DispatchQueue.main.async {
                self?.alert = .scheduleCreated(gotoSchedules: {
                    self?.navigationHelper.navigateToSchedules()
                })
            }
        }.store(in: &cancellables)
        
        createScheduleViewModel.presentViewPublisher.sink { [weak self] anyView in
            self?.sheetView = anyView
            self?.isSheetVisible = true
        }.store(in: &cancellables)
        
        createScheduleViewModel.onGotoDashboard
            .merge(with: selectTemplateVM.onGotoDashboard)
            .map { false }
            .assign(to: \.isSheetVisible, on: self)
            .store(in: &self.cancellables)
    }
    
    func createChecklist(for scheduleId: String, openAfterCreated: Bool) {
        firstly {
            scheduleDataSource.getSchedule(with: scheduleId)
        }.get { schedule in
            self.scheduleDataSource.deleteSchedule(schedule).catch {
                $0.log(message: "Failed to delete schedule")
            }
        }.then { schedule -> Promise<ChecklistDataModel> in
            let now = Date()
            return self.checklistDataSource.createChecklist(
                .init(
                    id: UUID().uuidString,
                    title: schedule.title,
                    description: schedule.description,
                    creationDate: now,
                    updateDate: now,
                    items: schedule.template.items
                )
            )
        }.get { checklist in
            after(seconds: 1).done {
                if openAfterCreated {
                    self.navigationHelper.navigateToChecklistDetail(with: checklist, shouldEdit: false)
                }
                self.notificationManager.clearDeeplinkcChecklistId()
            }
        }.catch { error in
            error.log(message: "Failed to create checklist for schedule ID: \(scheduleId)")
        }
    }
    
    func loadPendingSchedules() {
        notificationManager.getPendingSchedules().done { scheduleIds in
            scheduleIds.forEach {
                self.createChecklist(for: $0, openAfterCreated: false)
            }
        }
    }
    
    func handleDeleteChecklist(_ checklist: ChecklistDataModel) {
        alert = .confirmDeleteChecklist(onDelete: { [unowned self] in
            self.checklistDataSource.deleteChecklist(checklist)
            .done {
                Logger.log.debug("Checklist deleted with id: \(checklist.id)")
                Haptics.notify(.success)
            }.catch { _ in
                Logger.log.error("Delete checklist failed")
                Haptics.notify(.error)
            }
        })
    }
}


extension DashboardViewModel: ChecklistActionSheetDelegate {
    
    
    func onEditAction(checklist: ChecklistDataModel) {
        navigationHelper.navigateToChecklistDetail(with: checklist, shouldEdit: true)
    }
    
    func onMarkAllDoneAction(checklist: ChecklistDataModel) {
        alert = .confirmMarkAllItemsDone { [weak self] in
            guard let self = self else { return }
            var chcklst = checklist
            for i in 0...checklist.items.count-1 {
                chcklst.items[i].isDone = true
            }
            self.checklistDataSource.updateChecklist(chcklst).catch { error in
                error.log(message: "Failed to mark all items done")
            }
            
        }
    }
    
    func onMarkAllUndoneAction(checklist: ChecklistDataModel) {
        alert = .confirmMarkAllItemsUnDone { [weak self] in
            guard let self = self else { return }
            var chcklst = checklist
            for i in 0...checklist.items.count-1 {
                chcklst.items[i].isDone = false
            }
            self.checklistDataSource.updateChecklist(chcklst).catch { error in
                error.log(message: "Failed to mark all items undone")
            }
        }
    }
    
    func onSetReminderAction(checklist: ChecklistDataModel) {
        let vm = AppContext.resolver.resolve(EditReminderViewModel.self, argument: checklist)!
        vm.onDidDeleteReminder
            .merge(with: vm.onDidCreateReminder.map { _ in () })
            .sink { [weak self] in
                self?.sheet = .none
        }.store(in: &cancellables)
        self.sheet = .editReminder(viewModel: vm)
    }
    
    func onSaveAsTemplateAction(checklist: ChecklistDataModel) {
        templateDataSource.createTemplate(.init(checklist: checklist))
            .catch { $0.log(message: "Failed to create new template from checklist \(checklist)") }
    }
    
    func onDeleteAction(checklist: ChecklistDataModel) {
        handleDeleteChecklist(checklist)
    }
}
