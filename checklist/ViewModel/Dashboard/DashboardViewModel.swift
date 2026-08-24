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

enum DashboardPresentation: String, Identifiable {
    case sortAndFilter
    case actions
    case content

    var id: String { rawValue }
}

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
    @Published var alert: Alert = .empty
    @Published var isAlertVisible = false
    @Published var sheet: AnyView = .empty
    @Published var presentedSheet: DashboardPresentation?
    @Published var isEmptyListViewVisible = false
    @Published var isNoSearchResultsVisible = false
    @Published var isNoFilterResulrsVisible = false
    @Published var scrollToId: String?
    @Published var searchText = ""
    @Published var selectedSort: SortDataModel = .initial
    @Published var selectedFilter: FilterDataModel = .initial

    @Published var actionSheet: DashboardActionSheet = .none {
        didSet {
            if actionSheet.isActionSheedVisible {
                presentedSheet = .actions
            } else if presentedSheet == .actions {
                presentedSheet = nil
            }
        }
    }

    var isSheetVisible: Bool {
        get { presentedSheet == .content }
        set {
            if newValue {
                presentedSheet = .content
            } else if presentedSheet == .content {
                presentedSheet = nil
            }
        }
    }

    var isSortAndFilterPresented: Bool {
        get { presentedSheet == .sortAndFilter }
        set {
            if newValue {
                presentedSheet = .sortAndFilter
            } else if presentedSheet == .sortAndFilter {
                presentedSheet = nil
            }
        }
    }

    var isActionSheetPresented: Bool { actionSheet.isActionSheedVisible }

    func dismissActionSheet() {
        guard actionSheet.isActionSheedVisible else { return }
        isDismissingActionSheet = true
        actionSheet = .none
    }

    func didDismissPresentedSheet() {
        isDismissingActionSheet = false
        guard let pendingAlert else { return }
        self.pendingAlert = nil
        presentAlert(pendingAlert)
    }

    func updatePresentedSheet(_ presentation: DashboardPresentation?) {
        let previousPresentation = presentedSheet
        presentedSheet = presentation
        if presentation == nil, previousPresentation == .actions {
            actionSheet = .none
        }
    }
    
    let onCreateNewChecklist = EmptySubject()
    let onClearFilter = EmptySubject()
    
    var cancellables =  Set<AnyCancellable>()
    
    private var checklistToEdit: DashboardChecklistCellViewModel?
    private let checklistDataSource: ChecklistDataSource
    private let templateDataSource: TemplateDataSource
    private let scheduleDataSource: ScheduleDataSource
    private let notificationManager: NotificationManager
    private let checklistFilterAndSort: ChecklistFilterAndSort
    private let navigationHelper: NavigationHelper
    private let restrictionManager: RestrictionManager
    private var isDismissingActionSheet = false
    private var pendingAlert: Alert?
    
    init(
        checklistDataSource: ChecklistDataSource,
        templateDataSource: TemplateDataSource,
        scheduleDataSource: ScheduleDataSource,
        navigationHelper: NavigationHelper,
        checklistFilterAndSort: ChecklistFilterAndSort,
        notificationManager: NotificationManager,
        restrictionManager: RestrictionManager
    ) {
        self.checklistDataSource = checklistDataSource
        self.templateDataSource = templateDataSource
        self.checklistFilterAndSort = checklistFilterAndSort
        self.scheduleDataSource = scheduleDataSource
        self.notificationManager = notificationManager
        self.navigationHelper = navigationHelper
        self.restrictionManager = restrictionManager
        notificationManager.deeplinkChecklistId.sink { [weak self] checklistId in
            log(debug: "Did receive deepling cheklistId \(checklistId)")
            guard !checklistId.isEmpty else {
                return
            }
            guard let checklist = checklistDataSource.getChecklist(withId: checklistId) else {
                log(warning: "checklist with id \(checklistId) not found")
                return
            }
            log(debug: "Deeplinking to checklist: \(checklist)")
            self?.sheet = .empty
            self?.isSheetVisible = false
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
            .done { _ in Logger.log.debug("checklist created \(checklist)")}
            .catch { $0.log(message: "Create checklist failed") }
        }.store(in: &cancellables)
        
        onCreateNewChecklist.sink { [weak self] in
            self?.showChecklistView(state: .createChecklist)
        }.store(in: &cancellables)
        
        $searchText
            .map { $0.count > 2 ? $0 : nil }
            .assign(to: \ChecklistFilterAndSort.search, on: checklistFilterAndSort)
            .store(in: &cancellables)

        $selectedSort.dropFirst().sink { [weak self] sort in
            self?.checklistCells.removeAll()
            self?.checklistFilterAndSort.sort = sort
        }.store(in: &cancellables)

        $selectedFilter
            .dropFirst()
            .merge(with: onClearFilter.map { FilterDataModel.none })
            .sink { [weak self] filter in
            self?.checklistCells.removeAll()
                self?.selectedFilter = filter
                self?.checklistFilterAndSort.filter = filter
            }
            .store(in: &cancellables)
        
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
    
    func showChecklistView(state: ChecklistViewState) {
        let viewModel = AppContext.resolver.resolve(
            ChecklistViewModel.self,
            argument: state
        )!
        viewModel.onDidCreateTemplate.delay(for: .seconds(0.5), scheduler: RunLoop.main).sink { [weak self] in
            self?.alert = DashboardAlert.templateCreated(
                gotoTemplates: { self?.navigationHelper.navigateToMyTemplates() }
            ).alert
            self?.isAlertVisible = true
        }.store(in: &self.cancellables)
        viewModel.dismissView.sink { [weak self] in
            self?.sheet = .empty
            self?.isSheetVisible = false
        }.store(in: &cancellables)
        self.sheet = DashboardSheet.createChecklist(viewModel: viewModel).view
        self.isSheetVisible = true
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
        let confirmationAlert = DashboardAlert.confirmDeleteChecklist(onDelete: { [unowned self] in
            self.checklistDataSource.deleteChecklist(checklist)
            .done {
                Logger.log.debug("checklist deleted with id: \(checklist.id)")
                Haptics.notify(.success)
            }.catch { _ in
                Logger.log.error("Delete checklist failed")
                Haptics.notify(.error)
            }
        }).alert
        presentAlert(confirmationAlert)
    }

    func presentAlert(_ alert: Alert) {
        guard !isDismissingActionSheet else {
            pendingAlert = alert
            return
        }
        self.alert = alert
        isAlertVisible = true
    }
}


extension DashboardViewModel: ChecklistActionSheetDelegate {
    
    
    func onEditAction(checklist: ChecklistDataModel) {
        navigationHelper.navigateToChecklistDetail(with: checklist, shouldEdit: true)
    }
    
    func onMarkAllDoneAction(checklist: ChecklistDataModel) {
        let confirmationAlert = DashboardAlert.confirmMarkAllItemsDone { [weak self] in
            guard let self = self else { return }
            self.checklistDataSource.updateChecklist(checklist.getWithAllItemsDone()).catch { error in
                error.log(message: "Failed to mark all items done")
            }
        }.alert
        presentAlert(confirmationAlert)
    }
    
    func onMarkAllUndoneAction(checklist: ChecklistDataModel) {
        let confirmationAlert = DashboardAlert.confirmMarkAllItemsUnDone { [weak self] in
            guard let self = self else { return }
            self.checklistDataSource.updateChecklist(checklist.getWithAllItemsUndone()).catch { error in
                error.log(message: "Failed to mark all items undone")
            }
        }.alert
        presentAlert(confirmationAlert)
    }
    
    func onSaveAsTemplateAction(checklist: ChecklistDataModel) {
        firstly {
            restrictionManager.verifyCreateTemplate(presenter: self, isCreateFromScratch: true)
        }.then { verified -> Promise<Bool> in
            guard verified else {
                return .value(false)
            }
            return self.templateDataSource.createTemplate(.init(checklist: checklist)).map { verified }
        }.then { verified -> Promise<Bool> in
            guard verified else {
                return .value(false)
            }
            return after(seconds: 0.5).map { verified }
        }.get { verified in
            guard verified else {
                return
            }
            self.alert = DashboardAlert.templateCreated(gotoTemplates: { [weak self] in
                self?.navigationHelper.navigateToMyTemplates()
            }).alert
            self.isAlertVisible = true
        }.catch {
            $0.log(message: "Failed to create new template from checklist \(checklist)")
        }
    }
    
    func onDeleteAction(checklist: ChecklistDataModel) {
        handleDeleteChecklist(checklist)
    }
}


extension DashboardViewModel: RestrictionPresenter {
    
    func presentRestrictionAlert(_ alert: Alert) {
        self.alert = alert
        self.isAlertVisible = true
    }
    
    func presentUpgradeView(_ upgradeView: UpgradeView) {
        self.sheet = AnyView(upgradeView)
        self.isSheetVisible = true
    }
    
    func cancelUpgradeView() {
        dismissUpgradeView()
    }
    
    func dismissUpgradeView() {
        self.sheet = .empty
        self.isSheetVisible = false
    }
}
