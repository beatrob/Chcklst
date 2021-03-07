//
//  DashboardChecklistCell.swift
//  checklist
//
//  Created by Róbert Konczi on 12.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct DashboardChecklistCell: View {
    
    @ObservedObject var viewModel: DashboardChecklistCellViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text(viewModel.title)
                    .modifier(Modifiers.Checklist.SmallTitle())
                Spacer()
                if viewModel.isReminderSet {
                    Image(systemName: "bell.badge")
                }
                Text(viewModel.counter).modifier(Modifiers.Checklist.Item())
            }
            .padding(.top)
            .padding(.leading)
            .padding(.trailing)
            HStack {
                viewModel.firstUndoneItem.map {
                    ChecklistItemView(viewModel: $0)
                }
                Spacer()
            }
            .padding(.leading)
            .padding(.trailing)
            .padding(.bottom)
        }
        .onTapGesture {
            viewModel.onTapped.send()
        }
        .onLongPressGesture {
            viewModel.onLongTapped.send()
        }
        .background(Color.checklistBackground)
        .cornerRadius(20)
    }
}

struct DashboardChecklistCell_Previews: PreviewProvider {
    static var previews: some View {
        DashboardChecklistCell(
            viewModel: .init(
                checklist: .init(
                    id: "1234",
                    title: "Some cool checklist",
                    description: nil,
                    updateDate: Date(),
                    items: [
                        .init(id: "1234", name: "Let's do the dishes", isDone: false, updateDate: Date())
                    ]
                )
            )
        )
        .previewLayout(PreviewLayout.sizeThatFits)
        .padding()
        .previewDisplayName("Default preview")
    }
}
