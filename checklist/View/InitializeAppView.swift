//
//  InitializeAppView.swift
//  checklist
//
//  Created by Róbert Konczi on 28/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct InitializeAppView: View {
    
    let viewModel: InitializeAppViewModel
    
    var body: some View {
        VStack {
            viewModel.errorMessage.map {
                Text($0)
                    .foregroundColor(.red)
            }
            if viewModel.isLoading {
                Text("Loading ...")
            }
        }
    }
}

struct InitializeAppView_Previews: PreviewProvider {
    static var previews: some View {
        InitializeAppView(
            viewModel: .init(coreDataManager: MockCoreDataManager(), checklistDataSource: MockChecklistDataSource(), templateDataSource: MockTemplateDataSource(), initializeAppDataSource: InitializeAppDataSourceImpl(coreDataManager: MockCoreDataManager()))
        )
    }
}
