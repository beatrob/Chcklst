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
    var isEditable: Bool
    @State var textHeight: CGFloat = 150
    @State var isEditing: Bool = false
    @State var desiredHeight: CGFloat = 40
    
    var body: some View {
        VStack(alignment: .center) {
            MultilineTextView(
                text: $description,
                placeholder: "Description (optional)",
                font: Modifier.Checklist.Description.font,
                color: Modifier.Checklist.Description.color,
                isEditing: $isEditing,
                isCrossedOut: .constant(false),
                desiredHeight: $desiredHeight
            )
            .frame(height: desiredHeight)
            .modifier(Modifier.Checklist.TextField(isEditable: isEditable))
            .padding(.horizontal)
            .onTapGesture {
                if self.isEditable {
                    self.isEditing.toggle()
                }
            }
        }
    }
}

struct ChecklistDescriptionView_Previews: PreviewProvider {
    @State var name: String
    static var previews: some View {
        ChecklistDescriptionView(
            description: .constant("Some super description"),
            isEditable: false
        )
    }
}
