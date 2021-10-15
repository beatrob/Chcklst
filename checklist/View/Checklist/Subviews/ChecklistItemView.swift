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
                isCrossedOut: $viewModel.isDone
            )
        }
        .gesture(
            DragGesture(minimumDistance: 100.0, coordinateSpace: .local).onEnded { value in
                if value.location.x > value.startLocation.x, value.translation.width > 100 {
                    self.viewModel.onSwipeRight.send()
                } else if value.location.x < value.startLocation.x, value.translation.width < -100 {
                    self.viewModel.onSwipeLeft.send()
                }
            }
        )
    }
}

struct ChecklistItemView_Previews: PreviewProvider {
    static var previews: some View {
        ChecklistItemView(
            viewModel: .init(
                item: .init(
                    .init(
                        id: "123",
                        name: "Buy some good milk",
                        isDone: false,
                        updateDate: Date()
                    )
                )
            )
        ).previewLayout(.sizeThatFits)
    }
}
