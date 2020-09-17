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
    var shouldDisplayNextButton: Bool
    var items: [CreateChecklistItemVO]
    let onNext: EmptySubject
    
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
            items: [],
            onNext: .init()
        )
    }
}
