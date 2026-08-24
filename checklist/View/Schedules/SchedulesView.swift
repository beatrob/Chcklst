//
//  SchedulesView.swift
//  checklist
//
//  Created by Robert Konczi on 5/5/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct SchedulesView: View {
    
    @StateObject var viewModel: SchedulesViewModel
    @EnvironmentObject private var navigationHelper: NavigationHelper
    
    var body: some View {
        Group {
            if viewModel.isEmptyListViewVisible {
                EmptyListView(
                    message: """
                            Your schedule list is empty
                            To plan your checklists ahead start creating schedules from templates
                            """,
                    actionTitle: "Create schedule",
                    onActionTappedSubject: viewModel.onCreateSchedule
                )
            } else if viewModel.isNoSearchResultsVisible {
                EmptyListView(
                    message: "No results found",
                    actionTitle: nil,
                    onActionTappedSubject: nil
                )
            } else {
                List {
                    ForEach(viewModel.filteredCells) { cell in
                        ScheduleCellView(viewModel: cell)
                            .mainListRow()
                            .onTapGesture {
                                navigationHelper.navigateToScheduleDetail(id: cell.id)
                            }
                    }
                }
                .mainListStyle()
            }
        }
        .background(Color.mainBackground)
        .navigationTitle("Schedules")
        .navigationBarTitleDisplayMode(.inline)
        .if(viewModel.isSearchVisible) {
            $0.searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search schedules"
            )
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { viewModel.onCreateSchedule.send() } label: { Image(systemName: "plus") }
                    .accessibilityLabel("Create schedule")
            }
        }
        .chcklstNavigationBar()
        .sheet(isPresented: $viewModel.isSheetPresented) {
            viewModel.sheet
        }
    }
}

struct SchedulesView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SchedulesViewModel(
            scheduleDataSource: MockScheduleDataSource(),
            notificationManager: NotificationManager(checklistDataSource: MockChecklistDataSource())
        )
        viewModel.cells = MockScheduleDataSource.mockData.map {
            ScheduleCellViewModel(schedule: $0)
        }
        return SchedulesView( viewModel: viewModel)
    }
}
