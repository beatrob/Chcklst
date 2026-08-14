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

        navigationHelper.navigateToMyTemplates(source: .dashboard)
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

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
