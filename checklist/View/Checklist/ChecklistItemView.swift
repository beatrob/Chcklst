//
//  ChecklistItemView.swift
//  checklist
//
//  Created by Róbert Konczi on 16/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct ChecklistItemView: View {
    
    @ObservedObject var viewModel: ChecklistItemViewModel
    
    var body: some View {
        HStack {
            Image(systemName: viewModel.isDone ? "checkmark.circle" : "circle")
                .onTapGesture {
                    self.viewModel.onCheckMarkTapped.send()
                }
            Text(viewModel.name)
                .strikethrough(viewModel.isDone)
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
        )
    }
}
