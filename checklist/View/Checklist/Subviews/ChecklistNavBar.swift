//
//  ChecklistNavBarView.swift
//  checklist
//
//  Created by Róbert Konczi on 27.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI
import Combine


struct ChecklistNavBar: View {
    
    @StateObject var viewModel: ChecklistNavBarViewModel
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                NavBarChipButton(viewModel: viewModel.backButton)
                    .padding()
                Spacer()
                viewModel.reminderDate.map { date in
                    HStack {
                        if viewModel.isEditVisible {
                            Image(systemName: "bell.badge.fill")
                                .modifier(Modifiers.NavBar.Subtitle())
                            Text(date)
                                .modifier(Modifiers.NavBar.Subtitle())
                        }
                    }
                }
                if viewModel.isEditVisible {
                    NavBarChipButton(viewModel: viewModel.actionsButton)
                        .padding()
                } else {
                    NavBarChipButton(viewModel: viewModel.doneButton)
                        .padding()
                }
            }
        }
        .modifier(Modifiers.NavBar.NavBar())
    }
}


struct ChecklistNavBar_Preview: PreviewProvider {
    
    static var previews: some View {
        let viewModel = ChecklistNavBarViewModel(
            checklist: ChecklistDataModel(
                id: "",
                title: "",
                description: nil,
                updateDate: Date(),
                reminderDate: Date().addingTimeInterval(1000),
                items: [],
                isArchived: false
            )
        )
        return ChecklistNavBar(viewModel: viewModel)
            .previewLayout(.sizeThatFits)
    }
}
