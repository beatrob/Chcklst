//
//  ScheduleDetailView.swift
//  checklist
//
//  Created by Robert Konczi on 5/20/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct ScheduleDetailView: View {
    
    @StateObject var viewModel: ScheduleDetailViewModel
    @State var titleHeight: CGFloat = 40
    @State var descriptionHeight: CGFloat = 30
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.isNavbarVisible {
                BackButtonNavBar(viewModel: viewModel.navbarViewModel)
            }
            ScrollView {
                VStack(alignment: .leading) {
                    if !viewModel.isNavbarVisible  {
                        HStack {
                            NavBarChipButton(viewModel: viewModel.backButtonViewModel)
                            Spacer()
                            Text(viewModel.viewTitle)
                                .modifier(Modifier.Template.SmallTitle())
                            Spacer()
                        }.padding()
                    }
                    
                    MyTextField(
                        text: $viewModel.title,
                        placeholder: "Title",
                        font: .bigTitle,
                        isEditable: .constant(true),
                        isCrossedOut: .constant(false),
                        didEndEditing: nil
                    ).padding()
                    
                    MyTextField(
                        text: $viewModel.description,
                        placeholder: "Description",
                        font: .description,
                        isEditable: .constant(true),
                        isCrossedOut: .constant(false),
                        didEndEditing: nil
                    ).padding()
                    
                    ForEach(viewModel.items) {
                        ChecklistItemView(viewModel: $0)
                            .padding(.horizontal)
                    }
                    
                    Text("Schedule date")
                        .padding()
                        .modifier(Modifier.Checklist.SmallTitle())
                    HStack {
                        Spacer()
                        DatePicker(
                            "",
                            selection: $viewModel.date,
                            displayedComponents: [.date, .hourAndMinute]
                        ).labelsHidden()
                        Spacer()
                    }
                    
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            CheckboxView(viewModel: viewModel.repeatCheckboxViewModel)
                            if viewModel.isRepeatOn {
                                ForEach(viewModel.repeatFrequencyCheckboxes) {
                                    CheckboxView(viewModel: $0)
                                        .padding(.top)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        if viewModel.shouldDisplayDays {
                            VStack(alignment: .leading) {
                                Text("EVERY")
                                    .modifier(Modifier.Checklist.Description())
                                ForEach(viewModel.customDaysCheckboxes) {
                                    CheckboxView(viewModel: $0)
                                }
                            }
                            .padding(.leading)
                        } else {
                            Spacer()
                        }
                    }
                    .padding()
                    
                    HStack {
                        Spacer()
                        Button(viewModel.actionButtonTitle) {
                            viewModel.onActionButtonTapped.send()
                        }
                        .modifier(Modifier.Button.PrimaryAction())
                        .padding()
                        Spacer()
                    }.padding(.bottom)
                }
            }
        }
        .sheet(isPresented: $viewModel.isSheetPresented) {
            viewModel.sheet
        }
        .alert(isPresented: $viewModel.isAlertPresented) {
            viewModel.alert
        }
        .navigationBarHidden(true)
    }
}

struct ScheduleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScheduleDetailView(
                viewModel: .init(
                    state: .create(
                        template: .init(
                            id: "1",
                            title: "Some Template",
                            description: "This is a cool template for schedules",
                            items: [
                                .init(id: "1", name: "Item 1", isDone: false, updateDate: Date()),
                                .init(id: "2", name: "Item 2", isDone: false, updateDate: Date()),
                                .init(id: "3", name: "Item 3", isDone: false, updateDate: Date())
                            ]
                        )
                    ),
                    scheduleDataSource: MockScheduleDataSource(),
                    notificationManager: NotificationManager(),
                    restrictionManager: MockRestrictionManager()
                )
            )
            ScheduleDetailView(
                viewModel: .init(
                    state: .update(
                        schedule: .init(
                            id: "0",
                            title: "Some cool schedule",
                            description: "Some cool description",
                            template: .init(
                                id: "0",
                                title: "Some template",
                                description: "Some description",
                                items: [
                                    .init(
                                        id: "",
                                        name: "Item 1",
                                        isDone: false,
                                        updateDate: Date()
                                    ),
                                    .init(
                                        id: "",
                                        name: "Item 2",
                                        isDone: false,
                                        updateDate: Date()
                                    )
                                ]
                            ),
                            scheduleDate: Date(),
                            repeatFrequency: .customDays(days: [.monday, .wednesday])
                        )
                    ),
                    scheduleDataSource: MockScheduleDataSource(),
                    notificationManager: NotificationManager(),
                    restrictionManager: MockRestrictionManager()
                )
            )
        }
    }
}
