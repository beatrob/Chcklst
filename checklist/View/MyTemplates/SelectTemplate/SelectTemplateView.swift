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
                        Your template list empty.
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
        SelectTemplateView(
            viewModel: .init(
                checklistDataSource: MockChecklistDataSource(),
                templateDataSource: MockTemplateDataSource()
            )
        )
    }
}
