//
//  NameYourChecklistView.swift
//  checklist
//
//  Created by Róbert Konczi on 19/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI
import Combine

struct ChecklistDescriptionView: View {
    
    @Binding var description: String
    @Binding var isEditable: Bool
    @State var textHeight: CGFloat = 150
    @State var desiredHeight: CGFloat = 40
    
    var body: some View {
        VStack(alignment: .center) {
            MyTextField(
                text: $description,
                placeholder: "Description (optional)",
                font: .description,
                isEditable: $isEditable,
                isCrossedOut: .constant(false)
            )
            .padding(.horizontal)
        }
    }
}

struct ChecklistDescriptionView_Previews: PreviewProvider {
    @State var name: String
    static var previews: some View {
        ChecklistDescriptionView(
            description: .constant("Some super description"),
            isEditable: .constant(false)
        )
    }
}
