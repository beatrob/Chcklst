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
    @StateObject var viewModel: ChecklistViewModel
    
    var body: some View {
        if viewModel.shouldDismissView {
            presentationMode.wrappedValue.dismiss()
        }
        return GeometryReader { geometry in
            ZStack {
                NavigationLink(
                    destination: viewModel.navigationDestinationView,
                    isActive: $viewModel.isNavigationLinkActive,
                    label: { EmptyView() }
                )
                Color.mainBackground.ignoresSafeArea()
                VStack(spacing: 0) {
                    if viewModel.isNavBarVisible {
                        ChecklistNavBar(viewModel: viewModel.navBarViewModel)
                    } else {
                        BackButtonNavBar(viewModel: viewModel.createChecklistNavbarViewModel)
                    }
                    ScrollView {
                        VStack {
                            ChecklistNameView(
                                checklistName: $viewModel.checklistName,
                                isEditable: $viewModel.isEditable
                            )
                            if viewModel.shouldDisplayDescription {
                                ChecklistDescriptionView(
                                    description: $viewModel.checklistDescription,
                                    isEditable: $viewModel.isEditable
                                )
                                .padding(.bottom, 20)
                            }
                            ChecklistItemsView(
                                shouldDisplayAddItems: $viewModel.shouldDisplayAddItems,
                                items: viewModel.items,
                                onNext: viewModel.onAddItemsNext,
                                onDeleteItem: viewModel.onDeleteItem
                            )
                                .padding(.bottom)
                            if viewModel.shouldDisplaySetReminder {
                                CheckboxView(viewModel: viewModel.reminderCheckboxViewModel)
                                    .padding()
                                if viewModel.isReminderOn {
                                    HStack {
                                        Spacer()
                                        DatePicker("",
                                                   selection: $viewModel.reminderDate,
                                                   displayedComponents: [.date, .hourAndMinute]
                                        )
                                            .labelsHidden()
                                        Spacer()
                                    }
                                }
                            }
                            if viewModel.shouldDisplaySaveAsTemplate {
                                CheckboxView(viewModel: viewModel.saveAsTemplateCheckboxViewModel)
                                    .padding()
                            }
                            if viewModel.shouldDisplayActionButton {
                                HStack {
                                    Spacer()
                                    CapsuleButton(
                                        localizedKey: viewModel.actionButtonTitle,
                                        type: .primary,
                                        onTapSubject: viewModel.onActionButtonTapped
                                    )
                                        .padding(.vertical, 40)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .navigationBarHidden(true)
                .onTapGesture { self.hideKeyboard() }
                .alert(isPresented: self.$viewModel.alertVisibility.isVisible) {
                    viewModel.alertVisibility.view
                }
                .actionSheet(isPresented: self.$viewModel.actionSheetVisibility.isVisible, content: {
                    viewModel.actionSheetVisibility.view
                })
                .sheet(isPresented: self.$viewModel.sheetVisibility.isVisible) {
                    viewModel.sheetVisibility.view
                }
            }.ignoresSafeArea(.container, edges: .bottom)
        }
    }
}

struct CreateChecklistView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChecklistView(
                viewModel: ChecklistViewModel(
                    viewState: .display(checklist: .getWelcomeChecklist()),
                    checklistDataSource: MockChecklistDataSource(),
                    templateDataSource: MockTemplateDataSource(),
                    notificationManager: NotificationManager(),
                    restrictionManager: MockRestrictionManager()
                )
            )
            ChecklistView(
                viewModel: ChecklistViewModel(
                    viewState: .createNew,
                    checklistDataSource: MockChecklistDataSource(),
                    templateDataSource: MockTemplateDataSource(),
                    notificationManager: NotificationManager(),
                    restrictionManager: MockRestrictionManager()
                )
            )
        }
    }
}
