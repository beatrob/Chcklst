//
//  CreateChecklistView.swift
//  checklist
//
//  Created by Róbert Konczi on 19/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct CreateChecklistView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: CreateChecklistViewModel
    
    var body: some View {
        if viewModel.shouldDismissView {
            presentationMode.wrappedValue.dismiss()
        }
        return ScrollView {
            VStack {
                NameYourChecklistView(
                    checklistName: .init(
                        get: { self.viewModel.checklistName },
                        set: { self.viewModel.checklistName = $0 }
                    ),
                    shouldCreateChecklistName: $viewModel.shouldCreateChecklistName,
                    onNext: viewModel.onCreateTitleNext
                )
                AddItemsToChecklistView(
                    shouldDisplayAddItems: $viewModel.shouldDisplayAddItems,
                    shouldDisplayNextButton: viewModel.shouldDisplayNextAfterItems,
                    items: viewModel.items,
                    onNext: viewModel.onAddItemsNext
                )
                if viewModel.shouldDisplayFinalizeView {
                    FinalizeChecklistView(
                        viewModel: viewModel.getFinalizeCheckistViewModel()
                    )
                }
                if viewModel.shouldDisplayAddItems {
                    Spacer()
                }
            }
        }
    }
    
}

struct CreateChecklistView_Previews: PreviewProvider {
    static var previews: some View {
        CreateChecklistView(
            viewModel: .init(createChecklistSubject: .init(), notificationManager: NotificationManager())
        )
    }
}
