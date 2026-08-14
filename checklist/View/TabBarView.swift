import SwiftUI
import PromiseKit

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
    }

    var body: some View {
        TabView(selection: $navigationHelper.selectedTab) {
            NavigationStack(path: $navigationHelper.checklistPath) {
                DashboardView(viewModel: dashboardViewModel)
                    .navigationDestination(for: NavigationHelper.ChecklistRoute.self) { route in
                        ChecklistRouteDestination(route: route)
                    }
            }
            .tabItem { Label("Checklists", systemImage: "checklist") }
            .tag(NavigationHelper.AppTab.checklists)

            NavigationStack {
                MyTemplatesView(viewModel: templatesViewModel)
            }
            .tabItem { Label("Templates", systemImage: "doc.on.doc") }
            .tag(NavigationHelper.AppTab.templates)

            NavigationStack(path: $navigationHelper.schedulePath) {
                SchedulesView(viewModel: schedulesViewModel)
                    .navigationDestination(for: NavigationHelper.ScheduleRoute.self) { route in
                        ScheduleRouteDestination(route: route)
                    }
            }
            .tabItem { Label("Schedules", systemImage: "calendar") }
            .tag(NavigationHelper.AppTab.schedules)

            NavigationStack {
                SettingsView(viewModel: settingsViewModel)
            }
            .tabItem { Label("Settings", systemImage: "gearshape") }
            .tag(NavigationHelper.AppTab.settings)
        }
        .tint(.firstAccent)
        .environmentObject(navigationHelper)
    }
}

private struct ChecklistRouteDestination: View {

    let route: NavigationHelper.ChecklistRoute

    var body: some View {
        switch route {
        case .debugNotifications:
            DebugNotificationsView(viewModel: AppContext.resolver.resolve(DebugNotificationsViewModel.self)!)
        case .detail(let id, let shouldEdit):
            if let checklist = AppContext.resolver.resolve(ChecklistDataSource.self)!.getChecklist(withId: id) {
                ChecklistRouteContent(checklist: checklist, shouldEdit: shouldEdit)
            } else {
                MissingDestinationView(message: "This checklist is no longer available.")
            }
        }
    }
}

private struct ChecklistRouteContent: View {

    @EnvironmentObject private var navigationHelper: NavigationHelper
    @StateObject private var viewModel: ChecklistViewModel

    init(checklist: ChecklistDataModel, shouldEdit: Bool) {
        _viewModel = StateObject(wrappedValue: AppContext.resolver.resolve(
            ChecklistViewModel.self,
            argument: shouldEdit
                ? ChecklistViewState.updateChecklist(checklist: checklist)
                : ChecklistViewState.display(checklist: checklist)
        )!)
    }

    var body: some View {
        ChecklistView(viewModel: viewModel)
            .onReceive(viewModel.dismissView) { navigationHelper.checklistPath.removeLast() }
    }
}

private struct ScheduleRouteDestination: View {

    let route: NavigationHelper.ScheduleRoute
    @State private var viewModel: ScheduleDetailViewModel?
    @State private var isMissing = false

    var body: some View {
        Group {
            if let viewModel {
                ScheduleDetailView(viewModel: viewModel)
            } else if isMissing {
                MissingDestinationView(message: "This schedule is no longer available.")
            } else {
                ProgressView()
            }
        }
        .task(id: route) {
            guard case .detail(let id) = route else { return }
            AppContext.resolver.resolve(ScheduleDataSource.self)!
                .getSchedule(with: id)
                .done { schedule in
                    viewModel = AppContext.resolver.resolve(
                        ScheduleDetailViewModel.self,
                        argument: ScheduleDetailViewState.update(schedule: schedule)
                    )!
                }
                .catch { _ in isMissing = true }
        }
    }
}

private struct MissingDestinationView: View {

    let message: String

    var body: some View {
        Text(message)
            .foregroundColor(.secondary)
            .padding()
            .navigationTitle("Unavailable")
    }
}
