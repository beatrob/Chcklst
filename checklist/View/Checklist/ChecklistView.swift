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
                                    CheckboxView(
                                        title: "Remind me on this device",
                                        isChecked: $viewModel.isReminderOn
                                    )
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
                                    CheckboxView(
                                        title: "Save as template",
                                        isChecked: $viewModel.isCreateTemplateChecked
                                    )
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
                .onTapGesture { self.hideKeyboard() }
                .alert(isPresented: self.$viewModel.alertVisibility.isVisible) {
                    viewModel.alertVisibility.view
                }
                .sheet(
                    isPresented: Binding(
                        get: { viewModel.isActionSheetPresented },
                        set: { if !$0 { viewModel.dismissActionSheet() } }
                    ),
                    onDismiss: viewModel.didDismissActionSheet
                ) {
                    BottomActionSheet(title: viewModel.actionSheetTitle) {
                        viewModel.actionSheetButtons(onSelection: viewModel.selectActionSheetItem)
                    }
                }
                .sheet(isPresented: self.$viewModel.isSheetVisible) {
                    viewModel.sheet
                }
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewModel.viewState.isCreateChecklist {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showTemplatePicker()
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .accessibilityLabel("Choose template")
                }
            }
            if viewModel.isNavBarVisible {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isEditable {
                        Button("Done") { viewModel.navBarViewModel.doneButton.didTapSubject.send() }
                    } else {
                        Button { viewModel.navBarViewModel.actionsButton.didTapSubject.send() } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                        .accessibilityLabel("Checklist actions")
                    }
                }
            } else {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        viewModel.dismissView.send()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close \(viewModel.navigationTitle)")
                }
            }
        }
        .sheet(isPresented: $viewModel.isTemplatePickerVisible, onDismiss: viewModel.didDismissTemplatePicker) {
            NavigationStack {
                SelectTemplateView(
                    viewModel: viewModel.selectTemplateViewModel,
                    onTemplateSelected: viewModel.selectTemplate
                )
            }
        }
        .chcklstNavigationBar()
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
