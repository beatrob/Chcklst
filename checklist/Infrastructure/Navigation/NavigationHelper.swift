//
//  NavigationHelper.swift
//  checklist
//
//  Created by Róbert Konczi on 07/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI
final class NavigationHelper: ObservableObject {

    enum AppTab: Hashable {
        case checklists
        case templates
        case schedules
        case settings
    }

    enum ChecklistRoute: Hashable {
        case detail(id: String, shouldEdit: Bool)
        case debugNotifications
    }

    enum ScheduleRoute: Hashable {
        case detail(id: String)
    }

    @Published var selectedTab: AppTab = .checklists
    @Published var checklistPath: [ChecklistRoute] = []
    @Published var schedulePath: [ScheduleRoute] = []

    func navigateToSettings() {
        selectedTab = .settings
    }

    func navigateToSchedules() {
        selectedTab = .schedules
        schedulePath = []
    }

    func navigateToMyTemplates() {
        selectedTab = .templates
    }

    func navigateToChecklistDetail(with checklist: ChecklistDataModel, shouldEdit: Bool) {
        selectedTab = .checklists
        checklistPath = [
            checklist.title == DebugNotificationsViewModel.id
                ? .debugNotifications
                : .detail(id: checklist.id, shouldEdit: shouldEdit)
        ]
    }

    func navigateToScheduleDetail(id: String) {
        selectedTab = .schedules
        schedulePath.append(.detail(id: id))
    }

    func popToDashboard() {
        selectedTab = .checklists
        checklistPath = []
        schedulePath = []
    }

    var isOnDashboard: Bool {
        selectedTab == .checklists && checklistPath.isEmpty
    }
}
