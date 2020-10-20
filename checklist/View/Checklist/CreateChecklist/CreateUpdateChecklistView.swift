//
//  CreateChecklistView.swift
//  checklist
//
//  Created by Róbert Konczi on 19/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct CreateUpdateChecklistView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: CreateUpdateChecklistViewModel
    
    var body: some View {
        if viewModel.shouldDismissView {
            presentationMode.wrappedValue.dismiss()
        }
        return ScrollView {
            VStack {
                ChecklistNameView(
                    checklistName: .init(
                        get: { self.viewModel.checklistName },
                        set: { self.viewModel.checklistName = $0 }
                    ),
                    shouldCreateChecklistName: $viewModel.shouldCreateChecklistName,
                    isEditable: viewModel.isEditable,
                    onNext: viewModel.onCreateTitleNext
                )
                ChecklistItemsView(
                    shouldDisplayAddItems: $viewModel.shouldDisplayAddItems,
                    items: viewModel.items,
                    onNext: viewModel.onAddItemsNext,
                    onDeleteItem: viewModel.onDeleteItem
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
            .navigationBarTitle("Create checklist")
        }.onTapGesture { self.hideKeyboard() }
    }
    
}

struct CreateChecklistView_Previews: PreviewProvider {
    static var previews: some View {
        CreateUpdateChecklistView(
            viewModel: CreateUpdateChecklistViewModel(
                input: .init(
                    createChecklistSubject: .init(),
                    createTemplateSubject: .init(),
                    action: .createNew,
                    isEditable: true
                ),
                notificationManager: NotificationManager()
            )
        )
    }
}
