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
    @Published var scrollToId: String?
    
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
        
        notificationManager.deeplinkChecklistId.sink { [weak self] checklistId in
            log(debug: "Did receive deepling cheklistId \(checklistId)")
            guard !checklistId.isEmpty else {
                return
            }
            guard let checklist = checklistDataSource.getChecklist(withId: checklistId) else {
                log(warning: "Checklist with id \(checklistId) not found")
                return
            }
            log(debug: "Deeplinking to checklist: \(checklist)")
            self?.sheet = .none
            if !navigationHelper.isOnDashboard {
                navigationHelper.popToDashboard()
            }
            after(seconds: 0.5).done {
                navigationHelper.navigateToChecklistDetail(with: checklist, shouldEdit: false)
                notificationManager.clearDeeplinkChecklistId()
            }
        }.store(in: &cancellables)
        
        notificationManager.deeplinkScheduleId.sink { [weak self] scheduleId in
            guard !scheduleId.isEmpty else {
                return
            }
            self?.createChecklist(for: scheduleId)
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
                    self.showChecklistView(state: .createChecklist)
                },
                onNewFromTemplate: {
                    let viewModel = self.selectTemplateVM
                    viewModel.reset(
                        withTitle: "Create Checklist",
                        description: "Select a Template to create a new Checklist"
                    )
                    self.sheet = .selectTemplate(viewModel: viewModel)
                },
                onCreateTemplate: {
                    self.showChecklistView(state: .createTemplate)
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
        loadDeliveredReminders()
        
        AppContext.didEnterForeground.delay(for: .seconds(1), scheduler: RunLoop.main).sink { [weak self] in
            self?.loadDeliveredReminders()
        }.store(in: &cancellables)
    }
    
    func handleChecklistData(_ checklists: [ChecklistDataModel]) {
        scrollToId = nil
        var isDeleteDetected = false
        if checklistCells.isEmpty {
            checklistCells = checklists.map {
                self.getChecklistCellViewModel(with: $0)
            }
            return
        } else {
            // delete
            if checklists.count < self.checklistCells.count {
                isDeleteDetected = true
                let toDelete = self.checklistCells.enumerated().filter {
                    !checklists.contains($0.element.checklist)
                }
                toDelete.map { $0.offset }.forEach {
                    self.checklistCells.remove(at: $0)
                }
            }
            
            // update/insert
            checklists.enumerated().forEach { checklist in
                if checklist.offset < self.checklistCells.count {
                    self.checklistCells[checklist.offset].update(with: checklist.element)
                } else {
                    self.checklistCells.append(getChecklistCellViewModel(with: checklist.element))
                }
            }
            withAnimation {
                objectWillChange.send()
            }
        }
        if checklistFilterAndSort.sort == .latest && !isDeleteDetected {
            scrollToId = "top"
        }
    }
    
    func getChecklistCellViewModel(with checklist: ChecklistDataModel) -> DashboardChecklistCellViewModel {
        let viewModel = DashboardChecklistCellViewModel(
            checklist: checklist,
            checklistDataSource: self.checklistDataSource,
            itemDataSource: AppContext.resolver.resolve(ItemDataSource.self)!
        )
        
        viewModel.onChecklistTapped.sink { [weak self] checklist in
            guard let self = self else { return }
            firstly { () -> Promise<Void> in
                guard checklist.isNew else {
                    return .value
                }
                return self.checklistDataSource.updateChecklist(checklist.getWithCurrentUpdateDate())
            }.get {
                self.navigationHelper.navigateToChecklistDetail(with: checklist, shouldEdit: false)
            }.catch { error in
                error.log(message: "Failed to update checklist date.")
            }
        }.store(in: &cancellables)
        
        viewModel.onChecklistLongTapped.sink { [weak self] checklist in
            guard let self = self else {
                return
            }
            self.actionSheet = .editChecklist(checklist: checklist, delegate: self)
            Haptics.play(.actionSheet)
        }.store(in: &cancellables)
        
        viewModel.onDeleteCheklistTapped.sink { [unowned self] checklist in
            self.handleDeleteChecklist(checklist)
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
    
    func showChecklistView(state: ChecklistViewState) {
        let viewModel = AppContext.resolver.resolve(
            ChecklistViewModel.self,
            argument: state
        )!
        viewModel.onDidCreateTemplate.delay(for: .seconds(0.5), scheduler: RunLoop.main).sink { [weak self] in
            self?.alert = .templateCreated(
                gotoTemplates: { self?.navigationHelper.navigateToMyTemplates(source: .dashboard) }
            )
        }.store(in: &self.cancellables)
        viewModel.dismissView.sink { [weak self] in
            self?.sheet = .none
        }.store(in: &cancellables)
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
    
    func createChecklist(for scheduleId: String) {
        firstly {
            scheduleDataSource.getSchedule(with: scheduleId)
        }.then { schedule -> Promise<ScheduleDataModel> in
            guard schedule.repeatFrequency.isNever else {
                return .value(schedule)
            }
            return self.scheduleDataSource.deleteSchedule(schedule).map { schedule }
        }.then { schedule -> Promise<ChecklistDataModel> in
            let checklist = ChecklistDataModel(schedule: schedule)
            return self.checklistDataSource.createChecklist(checklist).map { checklist }
        }.get { checklist in
            self.notificationManager.clearDeeplinkChecklistId()
        }.then { _ in
            after(seconds: 1).done {
                self.navigationHelper.popToDashboard()
            }
        }.catch { error in
            error.log(message: "Failed to create checklist for schedule ID: \(scheduleId)")
        }
    }
    
    func loadDeliveredReminders() {
        notificationManager.getDeliveredReminders().done { reminders in
            reminders.scheduleIds.forEach {
                self.createChecklist(for: $0)
            }
            when(
                resolved: reminders.checklistIds.map {
                    self.checklistDataSource.deleteExpiredNotification(for: $0)
                }
            ).done { result in
                let failed = result.filter { !$0.isFulfilled }.count
                log(debug: "Remove expired reminders finished with \(failed) failures")
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
            self.checklistDataSource.updateChecklist(checklist.getWithAllItemsDone()).catch { error in
                error.log(message: "Failed to mark all items done")
            }
        }
    }
    
    func onMarkAllUndoneAction(checklist: ChecklistDataModel) {
        alert = .confirmMarkAllItemsUnDone { [weak self] in
            guard let self = self else { return }
            self.checklistDataSource.updateChecklist(checklist.getWithAllItemsUndone()).catch { error in
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
        templateDataSource.createTemplate(.init(checklist: checklist)).get {
            self.alert = .templateCreated(gotoTemplates: { [weak self] in
                self?.navigationHelper.navigateToMyTemplates(source: .dashboard)
            })
        }.catch {
            $0.log(message: "Failed to create new template from checklist \(checklist)")
        }
    }
    
    func onDeleteAction(checklist: ChecklistDataModel) {
        handleDeleteChecklist(checklist)
    }
}
