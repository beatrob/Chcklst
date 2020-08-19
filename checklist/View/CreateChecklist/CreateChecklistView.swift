//
//  CreateChecklistView.swift
//  checklist
//
//  Created by Róbert Konczi on 19/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct CreateChecklistView: View {
    
    @ObservedObject var viewModel: CreateChecklistViewModel
    
    var body: some View {
        VStack {
            NameYourChecklistView(
                checklistName: $viewModel.checklistName,
                shouldCreateChecklistName: $viewModel.shouldCreateChecklistName,
                onCreateFromTemplate: viewModel.onCreateFromTemplate,
                onNext: viewModel.onCreateTitleNext
            )
            AddItemsToChecklistView(
                shouldDisplayAddItems: $viewModel.shouldDisplayAddItems
            )
            if viewModel.shouldDisplayAddItems {
                Spacer()
            }
        }
    }
        
}

struct CreateChecklistView_Previews: PreviewProvider {
    static var previews: some View {
        CreateChecklistView(
            viewModel: .init(createChecklistSubject: .init())
        )
    }
}
