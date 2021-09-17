//
//  MyTemplatesView.swift
//  checklist
//
//  Created by Róbert Konczi on 30/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct SelectTemplateView: View {
    
    @ObservedObject var viewModel: SelectTemplateViewModel
    
    var body: some View {
        NavigationView {
            if viewModel.isEmptyListViewVisible {
                EmptyListView(
                    message: """
                        Your template list is empty.
                        Go to Dashboard to create a template from a new or an existing checklist
                        """,
                    actionTitle: "Go to Dashboard",
                    onActionTappedSubject: viewModel.onGotoDashboard
                )
            } else {
                VStack {
                    NavigationLink(
                        destination: viewModel.desitnationView,
                        isActive: $viewModel.isDestionationViewVisible,
                        label: {
                            EmptyView()
                        })
                    .isDetailLink(false)
                    .hidden()
                    
                    if let title = viewModel.title {
                        Text(title)
                            .modifier(Modifier.Template.SmallTitle())
                            .padding()
                    }
                    
                    if let description = viewModel.descriptionText {
                        Text(description)
                            .modifier(Modifier.Checklist.Description())
                            .padding(.bottom)
                            .padding(.horizontal)
                    }
                    
                    ForEach(
                        viewModel.templates,
                        id: \.id) { template in
                            MyTemplateItemView(
                                name: template.title,
                                description: template.description,
                                displayRightArrow: true
                            )
                                .onTapGesture {
                                    self.viewModel.onTemplateTapped.send(template)
                            }
                    }
                    Spacer()
                }
                .navigationBarHidden(true)
            }
        }
    }
}

struct SelectTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SelectTemplateViewModel(
            checklistDataSource: MockChecklistDataSource(),
            templateDataSource: MockTemplateDataSource()
        )
        viewModel.title = "Create Checklist"
        viewModel.descriptionText = "Select a Template to create a new Checklist"
        return SelectTemplateView(viewModel: viewModel)
    }
}
