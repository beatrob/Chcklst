//
//  ContentView.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct DashboardView: View {
    
    @ObservedObject var viewModel: DashboardViewModel
    @EnvironmentObject var navigationHelper: NavigationHelper
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("mainBackground")
                    .ignoresSafeArea()
                ScrollView {
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
                        
                        
                        VStack {
                            Spacer().frame(height: 15.0)
                            FilterView(viewModel: viewModel.filterViewModel)
                            HStack {
                                Text(viewModel.title)
                                    .font(.largeTitle)
                                    .foregroundColor(Color.white)
                                    .padding()
                                Spacer()
                            }
                        }.background(Color.blue)
                        ForEach(viewModel.checklistCells, id: \.id) { cell in
                            DashboardChecklistCell(viewModel: cell)
                                .padding(.horizontal, 20)
                                .padding(.vertical, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        }
                        Spacer()
                    }
                    .navigationBarTitle("C H C K ✓ L S T", displayMode: .inline)
                    .navigationBarItems(
                        leading: Button.init(
                            action: { self.viewModel.onSettings.send() },
                            label: {
                                Image(systemName: "gear")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                        ),
                        trailing: Button.init(
                            action: { self.viewModel.onCreateNewChecklist.send()},
                            label: {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                        )
                    )
                }
            }
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
        )
    }
}
