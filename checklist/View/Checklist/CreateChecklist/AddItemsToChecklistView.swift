//
//  AddItemsToChecklistView.swift
//  checklist
//
//  Created by Róbert Konczi on 19/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI
import Combine

struct AddItemsToChecklistView: View {
    
    @Binding var shouldDisplayAddItems: Bool
    @State var deletableItemIDs: Set<String> = .init()
    
    var shouldDisplayNextButton: Bool
    var items: [ChecklistItemViewModel]
    let onNext: EmptySubject
    let onDeleteItem: PassthroughSubject<ChecklistItemViewModel, Never>
    
    var body: some View {
        VStack {
            if shouldDisplayAddItems {
                VStack {
                    ForEach(items, id: \.id) { item in
                        HStack {
                            ChecklistItemView(viewModel: item)
                        }
                    }
                    .padding()
                    if shouldDisplayNextButton {
                        Button.init(action: {
                            self.onNext.send()
                        }) {
                            HStack {
                                Text("Next")
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }
}

struct AddItemsToChecklistView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemsToChecklistView(
            shouldDisplayAddItems: .init(get: { true }, set: { _ = $0 }),
            shouldDisplayNextButton: true,
            items: [
                ChecklistItemViewModel(id: "1", name: "Something", isDone: false)
            ],
            onNext: .init(),
            onDeleteItem: .init()
        )
    }
}
