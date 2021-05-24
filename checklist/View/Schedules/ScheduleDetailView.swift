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
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    NavBarChipButton(viewModel: viewModel.backButtonViewModel)
                    Spacer()
                }.padding()
                
                MultilineTextView(
                    text: $viewModel.title,
                    placeholder: "Title",
                    font: Font.Chcklst.bigTitle,
                    color: Color.firstAccent,
                    isEditing: .constant(true),
                    isCrossedOut: .constant(false),
                    desiredHeight: $titleHeight
                )
                .frame(height: titleHeight)
                .modifier(Modifier.Checklist.TextField(isEditable: true))
                .padding()
                
                MultilineTextView(
                    text: $viewModel.description,
                    placeholder: "Description",
                    font: Font.Chcklst.description,
                    color: Color.text,
                    isEditing: .constant(true),
                    isCrossedOut: .constant(false),
                    desiredHeight: $descriptionHeight
                )
                .frame(height: descriptionHeight)
                .modifier(Modifier.Checklist.TextField(isEditable: true))
                .padding()
                
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
                    .modifier(Modifier.Button.MainAction())
                    .padding()
                    Spacer()
                }.padding(.bottom)
                
                if viewModel.isDeleteButtonVisible {
                    HStack {
                        Spacer()
                        Button("Delete") {
                            viewModel.onDeleteButtonTapped.send()
                        }
                        .modifier(Modifier.Button.DestructiveAction())
                        .padding()
                        Spacer()
                    }.padding(.bottom)
                }
                Spacer()
                
                
            }
        }
        .alert(isPresented: $viewModel.isAlertPresented) {
            viewModel.alert
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
    }
}

struct ScheduleDetailView_Previews: PreviewProvider {
    static var previews: some View {
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
                scheduleDataSource: MockScheduleDataSource()
            )
        )
    }
}
