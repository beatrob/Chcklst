//
//  MyTemplatesView.swift
//  checklist
//
//  Created by Róbert Konczi on 30/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct MyTemplatesView: View {
    
    @ObservedObject var viewModel: MyTemplatesViewModel
    
    var body: some View {
        ZStack {
            Color.menuBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                if viewModel.isEmptyViewVisible {
                    EmptyListView(
                        message: "Your template list is empty.",
                        actionTitle: "Create template",
                        onActionTappedSubject: viewModel.onCreateTemplate
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(
                                viewModel.templates,
                                id: \.id) { template in
                                MyTemplateItemView(
                                    name: template.title,
                                    description: template.description,
                                    displayRightArrow: false
                                )
                                .onTapGesture {
                                    self.viewModel.onTemplateTapped.send(template)
                                }
                            }
                            Spacer()
                        }
                    }
                }
            }
            .background(Color.checklistBackground)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationTitle("Templates")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { viewModel.onCreateTemplate.send() } label: { Image(systemName: "plus") }
                    .accessibilityLabel("Create template")
            }
        }
        .chcklstNavigationBar()
        .sheet(isPresented: $viewModel.isSheetVisible) {
            self.viewModel.sheetView
        }
        .sheet(isPresented: $viewModel.isActionSheetVisible) {
            BottomActionSheet(title: viewModel.actionSheetTitle) {
                viewModel.actionSheetButtons(onSelection: {
                    viewModel.isActionSheetVisible = false
                })
            }
        }
        .alert(isPresented: $viewModel.isAlertVisible) {
            self.viewModel.alertView
        }
    }
}

struct MyTemplatesView_Previews: PreviewProvider {
    static var previews: some View {
        MyTemplatesView(
            viewModel: .init(
                templateDataSource: MockTemplateDataSource(),
                checklistDataSource: MockChecklistDataSource(),
                navigationHelper: NavigationHelper(),
                notificationManager: NotificationManager(checklistDataSource: MockChecklistDataSource())
            )
        )
    }
}
