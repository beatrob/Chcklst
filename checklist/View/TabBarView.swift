//
//  TabBarView.swift
//  checklist
//

import SwiftUI

struct TabBarView: View {

    @ObservedObject private var navigationHelper: NavigationHelper
    private let dashboardViewModel: DashboardViewModel
    private let templatesViewModel: MyTemplatesViewModel
    private let schedulesViewModel: SchedulesViewModel
    private let settingsViewModel: SettingsViewModel

    init(
        navigationHelper: NavigationHelper,
        dashboardViewModel: DashboardViewModel,
        templatesViewModel: MyTemplatesViewModel,
        schedulesViewModel: SchedulesViewModel,
        settingsViewModel: SettingsViewModel
    ) {
        self.navigationHelper = navigationHelper
        self.dashboardViewModel = dashboardViewModel
        self.templatesViewModel = templatesViewModel
        self.schedulesViewModel = schedulesViewModel
        self.settingsViewModel = settingsViewModel

        templatesViewModel.navBarViewModel.isBackButtonHidden = true
        schedulesViewModel.navBarViewModel.isBackButtonHidden = true
        settingsViewModel.navBarViewModel.isBackButtonHidden = true
    }

    var body: some View {
        TabView(selection: $navigationHelper.selectedTab) {
            DashboardView(viewModel: dashboardViewModel)
                .tabItem {
                    Label("Checklists", systemImage: "checklist")
                }
                .tag(NavigationHelper.AppTab.checklists)

            NavigationView {
                MyTemplatesView(viewModel: templatesViewModel)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Templates", systemImage: "doc.on.doc")
            }
            .tag(NavigationHelper.AppTab.templates)

            NavigationView {
                SchedulesView(viewModel: schedulesViewModel)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Schedules", systemImage: "calendar")
            }
            .tag(NavigationHelper.AppTab.schedules)

            NavigationView {
                SettingsView(viewModel: settingsViewModel)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(NavigationHelper.AppTab.settings)
        }
        .accentColor(.firstAccent)
        .environmentObject(navigationHelper)
        .onReceive(templatesViewModel.onBackTapped) {
            navigationHelper.popToDashboard()
        }
        .onReceive(templatesViewModel.onGotoSchedules) {
            navigationHelper.navigateToSchedules()
        }
        .onReceive(schedulesViewModel.onBackTapped) {
            navigationHelper.popToDashboard()
        }
        .onReceive(settingsViewModel.onBackTapped) {
            navigationHelper.popToDashboard()
        }
    }
}
