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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.mainBackground
                    .ignoresSafeArea()
                NavigationLinks()
                VStack(spacing: 0) {
                    DashboardNavBar(viewModel: .init())
                        .frame(height: 90)
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
                }.ignoresSafeArea()
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
                checklistFilter: ChecklistFilterImpl(dataSource: MockChecklistDataSource()),
                notificationManager: NotificationManager()
            )
        ).environmentObject(NavigationHelper())
    }
}
