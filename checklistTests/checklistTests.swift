//
//  checklistTests.swift
//  checklistTests
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import XCTest
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

}
