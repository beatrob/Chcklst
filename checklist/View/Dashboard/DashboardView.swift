//
//  ContentView.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct DashboardView: View {
    
    @StateObject var viewModel: DashboardViewModel
    private let sideMenuWidth: CGFloat = 200
    @State var text: String = ""
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .leading) {
                Color.mainBackground
                    .ignoresSafeArea()
                MenuView(viewModel: viewModel.menuViewModel)
                    .frame(width: sideMenuWidth)
                    .ignoresSafeArea()
                NavigationLinks()

                ZStack {
                    Color.menuBackground.ignoresSafeArea()
                    VStack(spacing: 0) {
                        DashboardNavBar(viewModel: viewModel.navBarViewModel)
                        if viewModel.isEmptyListViewVisible {
                            EmptyListView(
                                message: "Your checklist is empty",
                                actionTitle: "Create new",
                                onActionTappedSubject: viewModel.onCreateNewChecklist
                            )
                        } else if viewModel.isNoSearchResultsVisible {
                            EmptyListView(
                                message: "No results found",
                                actionTitle: nil,
                                onActionTappedSubject: nil
                            )
                        } else if viewModel.isNoFilterResulrsVisible {
                            EmptyListView(
                                message: "No results found",
                                actionTitle: "Clear filter",
                                onActionTappedSubject: viewModel.onClearFilter
                            )
                        } else {
                            ScrollView {
                                VStack {
                                    ForEach(viewModel.checklistCells, id: \.id) { cell in
                                        DashboardChecklistCell(viewModel: cell)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 7)
                                    }
                                }
                                .padding(.vertical)
                            }
                        }
                    }
                    .background(Color.mainBackground)
                    
                    if viewModel.isSidemenuVisible {
                        Color.mainBackground.opacity(viewModel.isSidemenuVisible ? 0.6 : 0)
                            .ignoresSafeArea()
                            .onTapGesture {
                                viewModel.onDarkOverlayTapped.send()
                            }
                    }
                }
                .ignoresSafeArea(.container, edges: .bottom)
                .offset(viewModel.isSidemenuVisible ? .init(width: sideMenuWidth, height: 0) : .zero)
            }
            .navigationBarHidden(true)
        }

        .alert(isPresented: $viewModel.alertVisibility.isVisible) {
            self.viewModel.alertVisibility.view
        }
        .actionSheet(isPresented: $viewModel.actionSheetVisibility.isVisible) {
            self.viewModel.actionSheetVisibility.view
        }
        .sheet(isPresented: $viewModel.isSheetVisible) {
            self.viewModel.sheetView
        }
    }
}


// MARK: - NavigationLinks

private struct NavigationLinks: View {
    
    @EnvironmentObject var navigationHelper: NavigationHelper
    
    var body: some View {
        VStack {
            NavigationLink(
                destination: navigationHelper.dashboardDestination,
                tag: .settings,
                selection: $navigationHelper.dashboardSelection
            ) {
                EmptyView()
            }
            .isDetailLink(false)
            .hidden()
            
            NavigationLink(
                destination: navigationHelper.dashboardDestination,
                tag: .checklistDetail,
                selection: $navigationHelper.dashboardSelection
            ) {
                EmptyView()
            }
            .isDetailLink(false)
            .hidden()
            
            NavigationLink(
                destination: navigationHelper.dashboardDestination,
                tag: .myTemplates,
                selection: $navigationHelper.dashboardSelection
            ) {
                EmptyView()
            }
            .isDetailLink(false)
            .hidden()
            
            NavigationLink(
                destination: navigationHelper.dashboardDestination,
                tag: .schedules,
                selection: $navigationHelper.dashboardSelection
            ) {
                EmptyView()
            }
            .isDetailLink(false)
            .hidden()
            
            NavigationLink(
                destination: navigationHelper.dashboardDestination,
                tag: .about,
                selection: $navigationHelper.dashboardSelection
            ) {
                EmptyView()
            }
            .isDetailLink(false)
            .hidden()
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(
            viewModel: DashboardViewModel(
                checklistDataSource: MockChecklistDataSource(),
                templateDataSource: MockTemplateDataSource(),
                scheduleDataSource: MockScheduleDataSource(),
                navigationHelper: NavigationHelper(),
                checklistFilterAndSort: ChecklistFilterAndSortImpl(dataSource: MockChecklistDataSource()),
                notificationManager: NotificationManager()
            )
        ).environmentObject(NavigationHelper())
    }
}
