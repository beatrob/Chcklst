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
                    VStack(spacing: 0) {
                        DashboardNavBar(viewModel: viewModel.navBarViewModel)
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
                    .background(Color.mainBackground)
                    .offset(viewModel.isSidemenuVisible ? .init(width: sideMenuWidth, height: 0) : .zero)
                    .ignoresSafeArea()
                    
                    Color.mainBackground.opacity(viewModel.isSidemenuVisible ? 0.6 : 0)
                        .ignoresSafeArea()
                        .offset(viewModel.isSidemenuVisible ? .init(width: sideMenuWidth, height: 0) : .zero)
                        .onTapGesture {
                            viewModel.onDarkOverlayTapped.send()
                        }
                }
            }
            .navigationBarHidden(true)
        }
        .alert(isPresented: $viewModel.alertVisibility.isVisible) {
            self.viewModel.alertVisibility.view
        }
        .actionSheet(isPresented: $viewModel.actionSheetVisibility.isVisible) {
            self.viewModel.actionSheetVisibility.view
        }
        .sheet(isPresented: $viewModel.sheetVisibility.isVisible) {
            self.viewModel.sheetVisibility.view
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
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(
            viewModel: DashboardViewModel(
                checklistDataSource: MockChecklistDataSource(),
                templateDataSource: MockTemplateDataSource(),
                navigationHelper: NavigationHelper(),
                checklistFilterAndSort: ChecklistFilterAndSortImpl(dataSource: MockChecklistDataSource()),
                notificationManager: NotificationManager()
            )
        ).environmentObject(NavigationHelper())
    }
}
