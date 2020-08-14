//
//  ChecklistView.swift
//  checklist
//
//  Created by Róbert Konczi on 14/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI
import Combine

struct ChecklistView: View {
    
    @ObservedObject var viewModel: ChecklistViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ChecklistView_Previews: PreviewProvider {
    static var previews: some View {
        ChecklistView(
            viewModel: .init(
                checklist: AnyPublisher(MockChecklistDataSource()._checkLists.eraseToAnyPublisher().map { $0.first! })
            )
        )
    }
}
