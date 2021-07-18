//
//  InitializeAppView.swift
//  checklist
//
//  Created by Róbert Konczi on 28/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI
import ActivityIndicatorView

struct InitializeAppView: View {
    
    @StateObject var viewModel: InitializeAppViewModel
    
    var body: some View {
        VStack {
            viewModel.errorMessage.map {
                Text($0)
                    .foregroundColor(.red)
            }
            if viewModel.isLoading {
                ActivityIndicatorView(isVisible: self.$viewModel.isLoading, type: .growingArc(.firstAccent))
                    .frame(width: 50, height: 50, alignment: .center)
                Text("Loading ...")
                    .padding(.top)
            }
        }
    }
}

struct InitializeAppView_Previews: PreviewProvider {
    static var previews: some View {
        InitializeAppView(
            viewModel: .init(
                coreDataManager: MockCoreDataManager(),
                checklistDataSource: MockChecklistDataSource(),
                templateDataSource: MockTemplateDataSource(),
                scheduleDataSource: MockScheduleDataSource(),
                initializeAppDataSource: InitializeAppDataSourceImpl(coreDataManager: MockCoreDataManager()))
        )
    }
}
