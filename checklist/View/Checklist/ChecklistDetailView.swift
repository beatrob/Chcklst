//
//  ChecklistView.swift
//  checklist
//
//  Created by Róbert Konczi on 14/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI
import Combine

struct ChecklistDetailView: View {
    
    @ObservedObject var viewModel: ChecklistDetailViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            viewModel.checklistVO.description.map {
                Text($0)
                    .font(.caption)
                    .lineLimit(nil)
                    .padding()
            }
            List(viewModel.checklistVO.items, id: \.id) { item in
                ChecklistItemView(viewModel: self.viewModel.getItemViewModel(for: item))
            }
        }
        .navigationBarTitle(
            Text(viewModel.checklistVO.title),
            displayMode: .large
        )
    }
}

struct ChecklistView_Previews: PreviewProvider {
    static var previews: some View {
        ChecklistDetailView(
            viewModel: .init(
                checklist: .init(MockChecklistDataSource()._checkLists.value.first),
                checklistDataSource: MockChecklistDataSource()
            )
        )
    }
}
