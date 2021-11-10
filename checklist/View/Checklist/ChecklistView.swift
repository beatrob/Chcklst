//
//  CreateChecklistView.swift
//  checklist
//
//  Created by Róbert Konczi on 19/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct ChecklistView: View {
    
    @StateObject var viewModel: ChecklistViewModel
    
    var body: some View {
        GeometryReader { geometry in
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
                        BackButtonNavBar(viewModel: viewModel.createViewNavbarViewModel)
                    }
                    ScrollView {
                        ScrollViewReader { scroller in
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
                                    .padding(.bottom, 30)
                                    .onChange(of: viewModel.items, perform: { _ in
                                        guard viewModel.enableAutoscrollToNewItem else {
                                            return
                                        }
                                        if let last = viewModel.items.last {
                                            withAnimation {
                                                scroller.scrollTo(last, anchor: .bottom)
                                            }
                                        }
                                    })
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
                }
                .navigationBarHidden(true)
                .onTapGesture { self.hideKeyboard() }
                .alert(isPresented: self.$viewModel.alertVisibility.isVisible) {
                    viewModel.alertVisibility.view
                }
                .actionSheet(isPresented: self.$viewModel.actionSheetVisibility.isVisible, content: {
                    viewModel.actionSheetVisibility.view
                })
                .sheet(isPresented: self.$viewModel.isSheetVisible) {
                    viewModel.sheet
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
                    notificationManager: NotificationManager(checklistDataSource: MockChecklistDataSource()),
                    restrictionManager: MockRestrictionManager()
                )
            )
            ChecklistView(
                viewModel: ChecklistViewModel(
                    viewState: .createChecklist,
                    checklistDataSource: MockChecklistDataSource(),
                    templateDataSource: MockTemplateDataSource(),
                    notificationManager: NotificationManager(checklistDataSource: MockChecklistDataSource()),
                    restrictionManager: MockRestrictionManager()
                )
            )
        }
    }
}
