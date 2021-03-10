//
//  AddItemsToChecklistView.swift
//  checklist
//
//  Created by Róbert Konczi on 19/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI
import Combine

struct ChecklistItemsView: View {
    
    @Binding var shouldDisplayAddItems: Bool
    @State var deletableItemIDs: Set<String> = .init()
    
    var items: [ChecklistItemViewModel]
    let onNext: EmptySubject
    let onDeleteItem: PassthroughSubject<ChecklistItemViewModel, Never>
    
    var body: some View {
        VStack {
            if shouldDisplayAddItems {
                VStack {
                    ForEach(items, id: \.id) { item in
                        ChecklistItemView(viewModel: item)
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                    }
                }
            }
        }
    }
}

struct AddItemsToChecklistView_Previews: PreviewProvider {
    static var previews: some View {
        ChecklistItemsView(
            shouldDisplayAddItems: .init(get: { true }, set: { _ = $0 }),
            items: [
                ChecklistItemViewModel(id: "1", name: "Something", isDone: false, isEditable: true)
            ],
            onNext: .init(),
            onDeleteItem: .init()
        )
    }
}
