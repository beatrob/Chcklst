//
//  MyTextField.swift
//  checklist
//
//  Created by Robert Konczi on 10/14/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct MyTextField: View {
    
    @Binding var text: String
    let placeholder: String
    let font: Font.Chcklst
    @Binding var isEditable: Bool
    @Binding var isCrossedOut: Bool
    
    @FocusState private var isTextEditorFocused
    
    var body: some View {
        ZStack(alignment: .leading) {
            if isEditable {
                TextEditor(text: $text)
                    .modifier(Modifier.TextField.Text(font: font))
                    .frame(minHeight: font.minimumTextFieldHeight)
                    .focused($isTextEditorFocused)
                    .padding(2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.text, lineWidth: 1)
                    )
            }
            if (isEditable && !isTextEditorFocused && text.isEmpty)
                || !isEditable {
                HStack {
                    Text(text.isEmpty ? placeholder : text)
                        .strikethrough(isCrossedOut)
                        .padding(.leading, 7)
                        .onTapGesture {
                            if isEditable {
                                isTextEditorFocused = true
                            }
                        }
                        .if(isEditable) {
                            $0.modifier(Modifier.TextField.Placeholder(font: font))
                        }.if(!isEditable) {
                            $0.modifier(Modifier.TextField.Text(font: font))
                        }
                    Spacer()
                }
            }
        }
    }
}

struct MyTextField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MyTextField(
                text: .constant("Very very very looong text to test if it can be split into two lines"),
                placeholder: "Placeholder",
                font: .bigTitle,
                isEditable: .constant(false),
                isCrossedOut: .constant(true)
            )
                .previewInterfaceOrientation(.portrait)
        }
    }
}
