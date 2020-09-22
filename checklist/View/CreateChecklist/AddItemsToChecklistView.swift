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
    var items: [CreateChecklistItemVO]
    let onNext: EmptySubject
    let onDeleteItem: PassthroughSubject<CreateChecklistItemVO, Never>
    
    var body: some View {
        VStack {
            if shouldDisplayAddItems {
                VStack {
                    ForEach(items, id: \.id) { item in
                        HStack {
                            Image(systemName: "circle")
                            TextField("TODO", text: item.$name, onEditingChanged: { _ in
                                if !item.name.isEmpty {
                                    self.deletableItemIDs.insert(item.id)
                                } else {
                                    self.deletableItemIDs.remove(item.id)
                                }
                            })
                            if self.deletableItemIDs.contains(item.id) {
                                Image(systemName: "xmark")
                                    .onTapGesture {
                                        withAnimation { self.onDeleteItem.send(item) }
                                }
                            }
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
            items: [.init(
                id: "1",
                name: .init(get: { "Item 1" }, set: { _ in }))],
            onNext: .init(),
            onDeleteItem: .init()
        )
    }
}
