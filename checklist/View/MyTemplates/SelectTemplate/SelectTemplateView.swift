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
    let onTemplateSelected: (TemplateDataModel) -> Void
    let onClose: EmptyCompletion
    @Environment(\.dismiss) private var dismiss
    
    init(
        viewModel: SelectTemplateViewModel,
        onTemplateSelected: @escaping (TemplateDataModel) -> Void,
        onClose: @escaping EmptyCompletion = {}
    ) {
        self.viewModel = viewModel
        self.onTemplateSelected = onTemplateSelected
        self.onClose = onClose
    }
    
    var body: some View {
        Group {
            if viewModel.isEmptyListViewVisible {
                EmptyListView(
                    message: """
                    Your template list is empty.
                    Create one on the Templates page.
                    """,
                    actionTitle: nil,
                    onActionTappedSubject: nil
                )
            } else {
                List {
                    ForEach(
                        viewModel.templates,
                        id: \.id) { template in
                            MyTemplateItemView(
                                name: template.title,
                                description: template.description
                            )
                            .mainListCardPadding()
                            .mainListCard(backgroundColor: .checklistBackground)
                            .mainListRow()
                            .onTapGesture {
                                onTemplateSelected(template)
                            }
                    }
                }
                .mainListStyle()
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    onClose()
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .accessibilityLabel("Close template picker")
            }
        }
        .navigationTitle("Select template")
        .navigationBarTitleDisplayMode(.inline)
        .chcklstNavigationBar()
    }
}

struct SelectTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SelectTemplateViewModel(
            templateDataSource: MockTemplateDataSource()
        )
        return NavigationStack {
            SelectTemplateView(viewModel: viewModel, onTemplateSelected: { _ in })
        }
    }
}
