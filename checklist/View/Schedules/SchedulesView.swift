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
    
    var body: some View {
        ZStack {
            Color.checklistBackground
            VStack(spacing: 0) {
                BackButtonNavBar(viewModel: viewModel.navBarViewModel)
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.cells) { cell in
                            ScheduleCellView(viewModel: cell)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 7)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.isSheetPresented) {
            viewModel.sheet
        }
    }
}

struct SchedulesView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SchedulesViewModel(scheduleDataSource: MockScheduleDataSource())
        viewModel.cells = MockScheduleDataSource.mockData.map {
            ScheduleCellViewModel(schedule: $0)
        }
        return SchedulesView( viewModel: viewModel)
    }
}
