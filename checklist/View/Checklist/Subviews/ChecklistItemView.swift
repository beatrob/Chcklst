//
//  ChecklistItemView.swift
//  checklist
//
//  Created by Róbert Konczi on 16/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct ChecklistItemView: View, Equatable {
    
    static func == (lhs: ChecklistItemView, rhs: ChecklistItemView) -> Bool {
        lhs.viewModel === rhs.viewModel
    }
    
    @ObservedObject var viewModel: ChecklistItemViewModel
    
    var body: some View {
        HStack {
            Image(systemName: viewModel.isDone ? "checkmark.circle" : "circle")
                .if(!viewModel.isEditable) {
                    $0.onTapGesture {
                        self.viewModel.onCheckMarkTapped.send()
                    }
                }
            MyTextField(
                text: $viewModel.name,
                placeholder: "Add task",
                font: .item,
                isEditable: $viewModel.isEditable,
                isCrossedOut: $viewModel.isDone,
                didEndEditing: viewModel.onDidEndEditing
            )
        }
        .onLongPressGesture { viewModel.onLongPress.send() }
    }
}

struct ChecklistItemView_Previews: PreviewProvider {
    static var previews: some View {
        ChecklistItemView(
            viewModel: .init(
                item: .init(
                    id: "123",
                    name: "Buy some good milk",
                    isDone: false,
                    updateDate: Date()
                ),
                checklistDataSource: MockChecklistDataSource()
            )
        ).previewLayout(.sizeThatFits)
    }
}
