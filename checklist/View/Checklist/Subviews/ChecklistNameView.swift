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
    @Binding var shouldCreateChecklistName: Bool
    var isEditable: Bool
    @State var textHeight: CGFloat = 100
    @State var isEditing: Bool = false
    @State var desiredHeight: CGFloat = 50
    
    var body: some View {
        VStack(alignment: .center) {
            MultilineTextView(
                text: $checklistName,
                placeholder: "Name your checklist",
                font: Modifier.Checklist.BigTitle.font,
                color: Modifier.Checklist.BigTitle.color,
                isEditing: $isEditing,
                isCrossedOut: .constant(false),
                desiredHeight: $desiredHeight
            )
            .frame(height: desiredHeight)
            .modifier(Modifier.Checklist.TextField(isEditable: isEditable))
            .padding()
            .onTapGesture {
                if self.isEditable {
                    self.isEditing.toggle()
                }
            }
        }
    }
}

struct NameYourChecklistView_Previews: PreviewProvider {
    @State var name: String
    static var previews: some View {
        ChecklistNameView(
            checklistName: .constant(""),
            shouldCreateChecklistName: .constant(true),
            isEditable: true
        )
    }
}
