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
        NavigationStack {
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
                    Form {
                        Section(header: Text("Templates")) {
                            ForEach(
                                viewModel.templates,
                                id: \.id) { template in
                                    Button {
                                        onTemplateSelected(template)
                                    } label: {
                                        MyTemplateItemView(
                                            name: template.title,
                                            description: template.description,
                                            displayRightArrow: false
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                        }
                    }
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
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .chcklstNavigationBar()
        }
    }
}

struct SelectTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SelectTemplateViewModel(
            templateDataSource: MockTemplateDataSource()
        )
        return SelectTemplateView(viewModel: viewModel, onTemplateSelected: { _ in })
    }
}
