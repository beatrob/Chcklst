//
//  MyTextField.swift
//  checklist
//
//  Created by Robert Konczi on 10/14/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI
import Combine

struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }

    typealias Value = CGFloat
}

struct MultilineTextField: View {
    
    @Binding var text: String
    @State var placeholder: String
    let font: Font.Chcklst
    @Binding var isEditable: Bool
    @Binding var isCrossedOut: Bool
    let didEndEditing: PassthroughSubject<Void, Never>?
    @FocusState private var isTextEditorFocused
    @State private var previousFocusedValue = false
    @State var width: CGFloat = 0
    var isPlaceholderActive: Bool {
        text.isEmpty && !isTextEditorFocused
    }
    let padding: CGFloat = 2
    
    var body: some View {
        HStack(spacing: 0) {
            if isEditable {
                TextEditor(text: isPlaceholderActive ? $placeholder : $text)
                    .multilineTextAlignment(.leading)
                    .modifier(Modifier.TextField.Text(font: font, isInPlaceholderMode: isPlaceholderActive))
                    .frame(minHeight: font.getMinimumTextFieldHeight(
                        for: isPlaceholderActive ? placeholder : text, width: width)
                    )
                    .focused($isTextEditorFocused)
                    .padding(padding)
                    .overlay(
                        GeometryReader { g in
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.text, lineWidth: 1)
                                .preference(key: WidthPreferenceKey.self, value: g.size.width)
                        }
                    )
                    .onChange(of: isTextEditorFocused) { isFocused in
                        if !isFocused && previousFocusedValue {
                            didEndEditing?.send()
                        }
                        previousFocusedValue = isFocused
                    }
            } else {
                HStack {
                    Text(text.isEmpty ? placeholder : text)
                        .strikethrough(isCrossedOut)
                        .padding(.leading, 7)
                        .modifier(Modifier.TextField.Text(font: font, isInPlaceholderMode: false))
                    Spacer()
                }
            }
        }
        .onPreferenceChange(WidthPreferenceKey.self) { width in
            self.width = width - (2 * padding + 10)
        }
    }
}

struct MyTextField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MultilineTextField(
                text: .constant("Very very very looong text to test if it can be split into two lines"),
                placeholder: "Placeholder",
                font: .bigTitle,
                isEditable: .constant(false),
                isCrossedOut: .constant(true),
                didEndEditing: nil
            )
                .previewInterfaceOrientation(.portrait)
        }
    }
}
