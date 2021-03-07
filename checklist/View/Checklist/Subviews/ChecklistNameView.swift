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
    let onNext: EmptySubject
    @State var textHeight: CGFloat = 150
    @State var isEditing: Bool = false
    @State var desiredHeight: CGFloat = 100
    
    var body: some View {
        VStack(alignment: .center) {
            MultilineTextView(
                text: $checklistName,
                placeholder: "Name your checklist",
                font: Modifiers.Checklist.BigTitle.font,
                color: Modifiers.Checklist.BigTitle.color,
                isEditing: $isEditing,
                isCrossedOut: .constant(false),
                desiredHeight: $desiredHeight
            )
                .frame(height: desiredHeight)
                .onTapGesture {
                    if self.isEditable {
                        self.isEditing.toggle()
                    }
                }
                .padding()
            if shouldCreateChecklistName {
                Button("Next") {
                    UIApplication.shared.endEditing()
                    withAnimation {
                        self.onNext.send()
                    }
                }
                .modifier(Modifiers.Button.MainAction())
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
            isEditable: true,
            onNext: .init()
        )
    }
}
