//
//  NameYourChecklistView.swift
//  checklist
//
//  Created by Róbert Konczi on 19/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI
import Combine

struct ChecklistNameView: View {
    
    @Binding var checklistName: String
    @Binding var isEditable: Bool
    
    var body: some View {
        VStack(alignment: .center) {
            MyTextField(
                text: $checklistName,
                placeholder: "Title",
                font: .bigTitle,
                isEditable: $isEditable,
                isCrossedOut: .constant(false),
                didEndEditing: nil
            )
            .padding()
        }
    }
}

struct NameYourChecklistView_Previews: PreviewProvider {
    @State var name: String
    static var previews: some View {
        ChecklistNameView(
            checklistName: .constant(""),
            isEditable: .constant(true)
        )
    }
}
