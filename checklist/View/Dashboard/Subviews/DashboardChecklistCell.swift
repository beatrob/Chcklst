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
        
        ZStack(alignment: .topTrailing) {
            VStack {
                HStack {
                    Text(viewModel.title)
                        .if(viewModel.shouldStrikeThroughTitle) {
                            $0.strikethrough()
                        }
                        .modifier(Modifier.Checklist.SmallTitle(color: .lightText))
                        
                    Spacer()
                    if viewModel.isReminderSet {
                        Image(systemName: "bell.badge")
                            .modifier(Modifier.Checklist.Item(color: .lightText))
                    }
                    Text(viewModel.counter).modifier(Modifier.Checklist.Item(color: .lightText))
                }
                .padding()
                .background(Color.firstAccent)
                .onTapGesture {
                    viewModel.onTapped.send()
                }.onLongPressGesture {
                    viewModel.onLongTapped.send()
                }
                
                if let firstUndone = viewModel.firstUndoneItem{
                    HStack {
                        ChecklistItemView(viewModel: firstUndone)
                        Spacer()
                    }
                    .padding()
                }
                
                if viewModel.shouldDisplayDeleteButton {
                    Button("Delete") {
                        viewModel.onDelete.send()
                    }
                    .padding()
                    .modifier(Modifier.Button.DestructiveAction())
                }
            }
            .background(Color.checklistBackground)
            .cornerRadius(20)
            .contentShape(Rectangle())
            
            if viewModel.shouldShowNewBadge {
                Text("New")
                    .padding(.horizontal, 8)
                    .font(Font.Chcklst.description.font)
                    .foregroundColor(.lightText)
                    .frame(height: 25)
                    .overlay(
                        Capsule()
                            .stroke(Color.alert)
                    ).background(
                        Capsule()
                            .fill(Color.alert)
                    )
                    .offset(CGSize(width: 10.0, height: -13.0))
            }
        }.id(viewModel.id)
    }
}

struct DashboardChecklistCell_Previews: PreviewProvider {
    static var previews: some View {
        let now = Date()
        return DashboardChecklistCell(
            viewModel: .init(
                checklist: .init(
                    id: "1234",
                    title: "Some cool checklist",
                    description: nil,
                    creationDate: now,
                    updateDate: now,
                    reminderDate: nil,
                    items: [
                        .init(id: "1234", name: "Let's do the dishes", isDone: false, updateDate: Date())
                    ]
                ),
                checklistDataSource: MockChecklistDataSource(),
                itemDataSource: MockItemDataSource()
            )
        )
        .previewLayout(PreviewLayout.sizeThatFits)
        .padding()
        .previewDisplayName("Default preview")
    }
}
