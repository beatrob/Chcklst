//
//  CreateChecklistView.swift
//  checklist
//
//  Created by Róbert Konczi on 19/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct ChecklistView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ChecklistViewModel
    
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
                if viewModel.shouldDisplaySetReminder {
                    CheckboxView(
                        title: "Remind me on this device",
                        isChecked: $viewModel.isReminderOn.animation()
                    ).padding()
                    if viewModel.isReminderOn {
                        HStack {
                            Spacer()
                            DatePicker("",
                                       selection: $viewModel.reminderDate,
                                       displayedComponents: [.date, .hourAndMinute]
                            ).labelsHidden()
                            Spacer()
                        }
                    }
                }
                if viewModel.shouldDisplaySaveAsTemplate {
                    CheckboxView(
                        title: "Also save as template",
                        isChecked: $viewModel.isCreateTemplateChecked
                    ).padding()
                }
                if viewModel.shouldDisplayActionButton {
                    HStack {
                        Spacer()
                        Button(viewModel.actionButtonTitle) {
                            self.viewModel.onActionButtonTapped.send()
                        }.padding()
                        Spacer()
                    }
                }
            }
            .navigationBarItems(trailing: viewModel.navigationBarTrailingItem)
            .navigationBarTitle(viewModel.navigationBarTitle, displayMode: viewModel.titleDisplayMode)
        }
        .onTapGesture { self.hideKeyboard() }
        .alert(isPresented: self.$viewModel.alertVisibility.isVisible) {
            viewModel.alertVisibility.view
        }
    }
}

struct CreateChecklistView_Previews: PreviewProvider {
    static var previews: some View {
        ChecklistView(
            viewModel: ChecklistViewModel(
                viewState: .createNew,
                checklistDataSource: MockChecklistDataSource(),
                templateDataSource: MockTemplateDataSource(),
                notificationManager: NotificationManager()
            )
        )
    }
}
