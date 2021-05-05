//
//  MyTextField.swift
//  checklist
//
//  Created by Robert Konczi on 4/30/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct MyTextField: UIViewRepresentable {
    
    @Binding var text: String
    let placeholder: String
    let font: Font.Chcklst
    let color: Color
    
    class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var text: String
        var didBecomeFirstResponder = false

        init(text: Binding<String>) {
            _text = text
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = font.uiFont
        textField.delegate = context.coordinator
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
}
