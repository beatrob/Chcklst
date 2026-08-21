//
//  checklistTests.swift
//  checklistTests
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import XCTest
import Combine
@testable import checklist

class checklistTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTabNavigationSelectsRequestedTabs() throws {
        let navigationHelper = NavigationHelper()

        XCTAssertEqual(navigationHelper.selectedTab, .checklists)

        navigationHelper.navigateToMyTemplates()
        XCTAssertEqual(navigationHelper.selectedTab, .templates)

        navigationHelper.navigateToSchedules()
        XCTAssertEqual(navigationHelper.selectedTab, .schedules)

        navigationHelper.navigateToSettings()
        XCTAssertEqual(navigationHelper.selectedTab, .settings)
    }

    func testPopToDashboardSelectsChecklistsTab() throws {
        let navigationHelper = NavigationHelper()
        navigationHelper.navigateToSettings()

        navigationHelper.popToDashboard()

        XCTAssertEqual(navigationHelper.selectedTab, .checklists)
        XCTAssertTrue(navigationHelper.isOnDashboard)
    }

    func testChecklistRouteUsesStableIdentifierAndCanBeReset() throws {
        let navigationHelper = NavigationHelper()
        let checklist = ChecklistDataModel.getWelcomeChecklist()

        navigationHelper.navigateToChecklistDetail(with: checklist, shouldEdit: true)

        XCTAssertEqual(navigationHelper.selectedTab, .checklists)
        XCTAssertEqual(
            navigationHelper.checklistPath,
            [.detail(id: checklist.id, shouldEdit: true)]
        )

        navigationHelper.popToDashboard()
        XCTAssertTrue(navigationHelper.checklistPath.isEmpty)
    }

    func testScheduleRouteKeepsChecklistHistoryIndependent() throws {
        let navigationHelper = NavigationHelper()
        let checklist = ChecklistDataModel.getWelcomeChecklist()
        navigationHelper.navigateToChecklistDetail(with: checklist, shouldEdit: false)

        navigationHelper.navigateToScheduleDetail(id: "schedule-id")

        XCTAssertEqual(navigationHelper.selectedTab, .schedules)
        XCTAssertEqual(navigationHelper.schedulePath, [.detail(id: "schedule-id")])
        XCTAssertEqual(navigationHelper.checklistPath, [.detail(id: checklist.id, shouldEdit: false)])

        navigationHelper.dismissScheduleDetail()

        XCTAssertTrue(navigationHelper.schedulePath.isEmpty)
        XCTAssertEqual(navigationHelper.checklistPath, [.detail(id: checklist.id, shouldEdit: false)])
    }

    func testSettingsAboutActionsPresentSheets() throws {
        let viewModel = SettingsViewModel(
            navigationHelper: NavigationHelper(),
            restrictionManager: MockRestrictionManager(),
            purchaseManager: MockPurchaseManager(),
            appearanceManager: AppearanceManager(),
            notificationManager: NotificationManager(checklistDataSource: MockChecklistDataSource())
        )

        viewModel.onHelp.send()
        XCTAssertTrue(viewModel.isSheetVisible)

        viewModel.isSheetVisible = false
        viewModel.onTermsAndConditions.send()
        XCTAssertTrue(viewModel.isSheetVisible)

        viewModel.isSheetVisible = false
        viewModel.onPrivacyPolicy.send()
        XCTAssertTrue(viewModel.isSheetVisible)
    }

    func testDashboardDeletePresentsConfirmationAfterActionsSheetDismisses() {
        let checklistDataSource = MockChecklistDataSource()
        let viewModel = DashboardViewModel(
            checklistDataSource: checklistDataSource,
            templateDataSource: MockTemplateDataSource(),
            scheduleDataSource: MockScheduleDataSource(),
            navigationHelper: NavigationHelper(),
            checklistFilterAndSort: ChecklistFilterAndSortImpl(dataSource: checklistDataSource),
            notificationManager: NotificationManager(checklistDataSource: checklistDataSource),
            restrictionManager: MockRestrictionManager()
        )
        let checklist = ChecklistDataModel.getWelcomeChecklist()
        viewModel.actionSheet = .editChecklist(checklist: checklist, delegate: viewModel)

        viewModel.dismissActionSheet()
        viewModel.onDeleteAction(checklist: checklist)

        XCTAssertFalse(viewModel.isAlertVisible)

        viewModel.didDismissPresentedSheet()

        XCTAssertTrue(viewModel.isAlertVisible)
    }

    func testDashboardCreatePresentsChecklistSheetWithoutActionSheet() {
        let checklistDataSource = MockChecklistDataSource()
        let viewModel = DashboardViewModel(
            checklistDataSource: checklistDataSource,
            templateDataSource: MockTemplateDataSource(),
            scheduleDataSource: MockScheduleDataSource(),
            navigationHelper: NavigationHelper(),
            checklistFilterAndSort: ChecklistFilterAndSortImpl(dataSource: checklistDataSource),
            notificationManager: NotificationManager(checklistDataSource: checklistDataSource),
            restrictionManager: MockRestrictionManager()
        )

        viewModel.onCreateNewChecklist.send()

        XCTAssertTrue(viewModel.isSheetVisible)
        XCTAssertFalse(viewModel.isActionSheetPresented)
    }

    func testSelectingTemplateAppliesItToEmptyChecklistDraft() {
        let viewModel = makeCreateChecklistViewModel()
        let template = makeTemplate()
        let reminderDate = Date(timeIntervalSince1970: 1_000)
        viewModel.reminderDate = reminderDate
        viewModel.isCreateTemplateChecked = true

        viewModel.selectTemplate(template)
        viewModel.didDismissTemplatePicker()

        XCTAssertEqual(viewModel.checklistName, template.title)
        XCTAssertEqual(viewModel.checklistDescription, template.description)
        XCTAssertEqual(viewModel.items.map(\.name).filter { !$0.isEmpty }, template.items.map(\.name))
        XCTAssertEqual(viewModel.reminderDate, reminderDate)
        XCTAssertTrue(viewModel.isCreateTemplateChecked)
        XCTAssertFalse(viewModel.alertVisibility.isVisible)
    }

    func testSelectingTemplateForPopulatedDraftRequiresReplacementConfirmation() {
        let viewModel = makeCreateChecklistViewModel()
        viewModel.checklistName = "Draft"

        viewModel.selectTemplate(makeTemplate())
        viewModel.didDismissTemplatePicker()

        XCTAssertEqual(viewModel.checklistName, "Draft")
        XCTAssertTrue(viewModel.alertVisibility.isVisible)
    }

    func testCreateTemplateUsesModalNavigationBar() {
        let viewModel = ChecklistViewModel(
            viewState: .createTemplate,
            checklistDataSource: MockChecklistDataSource(),
            templateDataSource: MockTemplateDataSource(),
            notificationManager: NotificationManager(checklistDataSource: MockChecklistDataSource()),
            restrictionManager: MockRestrictionManager()
        )

        XCTAssertEqual(viewModel.navigationTitle, "Create template")
        XCTAssertFalse(viewModel.isNavBarVisible)
    }

    func testCancellingUpgradeDismissesPurchaseSheetFromCreateTemplate() {
        let viewModel = ChecklistViewModel(
            viewState: .createTemplate,
            checklistDataSource: MockChecklistDataSource(),
            templateDataSource: MockTemplateDataSource(),
            notificationManager: NotificationManager(checklistDataSource: MockChecklistDataSource()),
            restrictionManager: MockRestrictionManager()
        )
        viewModel.presentUpgradeView(
            UpgradeView(viewModel: UpgradeViewModel(purchaseManager: MockPurchaseManager()))
        )

        XCTAssertTrue(viewModel.isSheetVisible)

        viewModel.cancelUpgradeView()

        XCTAssertFalse(viewModel.isSheetVisible)
    }

    func testChecklistMarkAllDoneWaitsForActionSheetDismissal() {
        let checklist = ChecklistDataModel.getWelcomeChecklist()
        let viewModel = makeChecklistDetailViewModel(checklist: checklist)
        viewModel.navBarViewModel.actionsButton.didTapSubject.send()

        XCTAssertTrue(viewModel.isActionSheetPresented)

        viewModel.selectActionSheetItem {
            viewModel.onMarkAllDoneAction(checklist: checklist)
        }

        XCTAssertFalse(viewModel.isActionSheetPresented)
        XCTAssertFalse(viewModel.alertVisibility.isVisible)

        viewModel.didDismissActionSheet()

        XCTAssertTrue(viewModel.alertVisibility.isVisible)
    }

    func testChecklistDeleteWaitsForActionSheetDismissal() {
        let checklist = ChecklistDataModel.getWelcomeChecklist()
        let viewModel = makeChecklistDetailViewModel(checklist: checklist)
        viewModel.navBarViewModel.actionsButton.didTapSubject.send()

        XCTAssertTrue(viewModel.isActionSheetPresented)

        viewModel.selectActionSheetItem {
            viewModel.onDeleteAction(checklist: checklist)
        }

        XCTAssertFalse(viewModel.isActionSheetPresented)
        XCTAssertFalse(viewModel.alertVisibility.isVisible)

        viewModel.didDismissActionSheet()

        XCTAssertTrue(viewModel.alertVisibility.isVisible)
    }

    func testReminderCheckboxMatchesChecklistWhenEnteringEditMode() {
        let source = ChecklistDataModel.getWelcomeChecklist()
        let reminderDate = Date().addingTimeInterval(3_600)
        let checklist = ChecklistDataModel(
            id: source.id,
            title: source.title,
            description: source.description,
            creationDate: source.creationDate,
            updateDate: source.updateDate,
            reminderDate: reminderDate,
            items: source.items
        )
        let viewModel = makeChecklistDetailViewModel(checklist: checklist)
        viewModel.isReminderOn = false

        viewModel.onEditAction(checklist: checklist)

        XCTAssertTrue(viewModel.isReminderOn)
        XCTAssertEqual(viewModel.reminderDate, reminderDate)
    }

    func testFirstReminderUncheckUpdatesCheckboxAndReminderState() {
        let source = ChecklistDataModel.getWelcomeChecklist()
        let checklist = ChecklistDataModel(
            id: source.id,
            title: source.title,
            description: source.description,
            creationDate: source.creationDate,
            updateDate: source.updateDate,
            reminderDate: Date().addingTimeInterval(3_600),
            items: source.items
        )
        let viewModel = makeChecklistDetailViewModel(checklist: checklist)
        viewModel.onEditAction(checklist: checklist)

        viewModel.isReminderOn.toggle()

        XCTAssertFalse(viewModel.isReminderOn)
    }

    func testUncheckedReminderIsNotSavedWithChecklist() {
        let checklistDataSource = MockChecklistDataSource()
        let viewModel = ChecklistViewModel(
            viewState: .createChecklist,
            checklistDataSource: checklistDataSource,
            templateDataSource: MockTemplateDataSource(),
            notificationManager: NotificationManager(checklistDataSource: checklistDataSource),
            restrictionManager: MockRestrictionManager()
        )
        viewModel.checklistName = "No reminder"
        viewModel.reminderDate = Date().addingTimeInterval(3_600)
        let didCreate = expectation(description: "Checklist created")
        let cancellable = viewModel.onDidCreateChecklist.sink {
            didCreate.fulfill()
        }

        viewModel.onActionButtonTapped.send()

        wait(for: [didCreate], timeout: 1)
        XCTAssertEqual(checklistDataSource._checkLists.value.first?.title, "No reminder")
        XCTAssertNil(checklistDataSource._checkLists.value.first?.reminderDate)
        withExtendedLifetime(cancellable) {}
    }

    func testSelectingTemplatePushesCreateScheduleDetail() {
        let createSubject = EmptySubject()
        let viewModel = CreateScheduleViewModel(
            createPublisher: createSubject.eraseToAnyPublisher()
        )

        viewModel.selectTemplate(makeTemplate())

        XCTAssertTrue(viewModel.isScheduleDetailPresented)
        XCTAssertEqual(viewModel.scheduleDetailViewModel?.viewTitle, "Create schedule")

        viewModel.isScheduleDetailPresented = false

        XCTAssertFalse(viewModel.isScheduleDetailPresented)
    }

    func testTemplateActionRunsAfterActionSheetDismissal() {
        let viewModel = MyTemplatesViewModel(
            templateDataSource: MockTemplateDataSource(),
            checklistDataSource: MockChecklistDataSource(),
            navigationHelper: NavigationHelper(),
            notificationManager: NotificationManager(checklistDataSource: MockChecklistDataSource())
        )
        var didRunAction = false

        viewModel.selectActionSheetItem {
            didRunAction = true
        }

        XCTAssertFalse(didRunAction)

        viewModel.didDismissActionSheet()

        XCTAssertTrue(didRunAction)
    }

    func testTemplatesDoesNotShowCreationAlertForUnrelatedChecklistChanges() {
        let checklistDataSource = MockChecklistDataSource()
        let viewModel = MyTemplatesViewModel(
            templateDataSource: MockTemplateDataSource(),
            checklistDataSource: checklistDataSource,
            navigationHelper: NavigationHelper(),
            notificationManager: NotificationManager(checklistDataSource: checklistDataSource)
        )

        _ = checklistDataSource.createChecklist(.getWelcomeChecklist())

        let alertDelayElapsed = expectation(description: "Old delayed alert would have been presented")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            XCTAssertFalse(viewModel.isAlertVisible)
            alertDelayElapsed.fulfill()
        }
        wait(for: [alertDelayElapsed], timeout: 2)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    private func makeCreateChecklistViewModel() -> ChecklistViewModel {
        ChecklistViewModel(
            viewState: .createChecklist,
            checklistDataSource: MockChecklistDataSource(),
            templateDataSource: MockTemplateDataSource(),
            notificationManager: NotificationManager(checklistDataSource: MockChecklistDataSource()),
            restrictionManager: MockRestrictionManager()
        )
    }

    private func makeChecklistDetailViewModel(checklist: ChecklistDataModel) -> ChecklistViewModel {
        ChecklistViewModel(
            viewState: .display(checklist: checklist),
            checklistDataSource: MockChecklistDataSource(),
            templateDataSource: MockTemplateDataSource(),
            notificationManager: NotificationManager(checklistDataSource: MockChecklistDataSource()),
            restrictionManager: MockRestrictionManager()
        )
    }

    private func makeTemplate() -> TemplateDataModel {
        TemplateDataModel(
            id: "template-id",
            title: "Morning routine",
            description: "Start well",
            items: [
                ItemDataModel(id: "item-1", name: "Coffee", isDone: false, updateDate: .now),
                ItemDataModel(id: "item-2", name: "Plan day", isDone: false, updateDate: .now)
            ],
            created: .now
        )
    }

}
