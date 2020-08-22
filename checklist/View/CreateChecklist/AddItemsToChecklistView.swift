//
//  AddItemsToChecklistView.swift
//  checklist
//
//  Created by Róbert Konczi on 19/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct AddItemsToChecklistView: View {
    
    @Binding var shouldDisplayAddItems: Bool
    var shouldDisplayCreateButton: Bool
    var items: [CreateChecklistItemVO]
    let onCreate: EmptySubject
    
    var body: some View {
        VStack {
            if shouldDisplayAddItems {
                VStack {
                    ForEach(items, id: \.id) { item in
                        HStack {
                            Image(systemName: "circle")
                            TextField("TODO", text: item.$name)
                        }
                    }
                    .padding()
                    if shouldDisplayCreateButton {
                        Button.init(action: {
                            self.onCreate.send()
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Create checklist")
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
            shouldDisplayCreateButton: true,
            items: [],
            onCreate: .init()
        )
    }
}
