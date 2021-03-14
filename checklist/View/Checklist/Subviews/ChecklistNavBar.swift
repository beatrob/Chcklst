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
                        if !viewModel.shouldDisplayDoneButton {
                            Image(systemName: "bell.badge.fill")
                                .modifier(Modifier.NavBar.Subtitle())
                            Text(date)
                                .modifier(Modifier.NavBar.Subtitle())
                        }
                    }
                }
                if !viewModel.shouldDisplayDoneButton {
                    NavBarChipButton(viewModel: viewModel.actionsButton)
                        .padding()
                } else {
                    NavBarChipButton(viewModel: viewModel.doneButton)
                        .padding()
                }
            }
        }
        .modifier(Modifier.NavBar.NavBar())
    }
}


struct ChecklistNavBar_Preview: PreviewProvider {
    
    static var previews: some View {
        let viewModel = ChecklistNavBarViewModel(
            checklist: Just(
                ChecklistDataModel(
                    id: "",
                    title: "",
                    description: nil,
                    updateDate: Date(),
                    reminderDate: Date().addingTimeInterval(1000),
                    items: [],
                    isArchived: false
                )
            ).eraseToAnyPublisher()
        )
        return ChecklistNavBar(viewModel: viewModel)
            .previewLayout(.sizeThatFits)
    }
}
