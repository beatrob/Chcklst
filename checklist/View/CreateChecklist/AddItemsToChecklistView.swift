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
    
    var body: some View {
        VStack {
            if shouldDisplayAddItems {
                Text("Add Items")
            }
        }
    }
}

struct AddItemsToChecklistView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemsToChecklistView(
            shouldDisplayAddItems: .init(get: { true }, set: { _ = $0 })
        )
    }
}
