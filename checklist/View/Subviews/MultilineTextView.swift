//
//  MultilineTextView.swift
//  checklist
//
//  Created by Róbert Konczi on 18/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit


struct MultilineTextView: UIViewRepresentable {
    
    class ChecklistItemUITextView: UIView {
         
        private let textView = UITextView()
        private let labelView = UILabel()
        private let placeholder: String?
        
        var font: UIFont = .systemFont(ofSize: 16) {
            didSet {
                setupFonts()
            }
        }
        
        var textColor: UIColor = .label {
            didSet {
                textView.textColor = textColor
                labelView.textColor = textColor
            }
        }
        
        var isEditing: Bool = false {
            didSet {
                setupSubviewsVisibility()
            }
        }
        
        var text: String? {
            didSet {
                textView.text = text
                if text == nil || (text?.isEmpty ?? true) {
                    labelView.text = placeholder
                    labelView.alpha = 0.5
                } else {
                    labelView.text = text
                    labelView.alpha = 1
                }
            }
        }
        
        var attributedText: NSAttributedString? {
            didSet {
                labelView.attributedText = attributedText
            }
        }
        
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        init(isEditing: Bool, placeholder: String?) {
            self.placeholder = placeholder
            super.init(frame: .zero)
            
            setupSubviewsVisibility()
            setupFonts()
            textView.isScrollEnabled = true
            textView.isEditable = true
            textView.isUserInteractionEnabled = true
            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0
            textView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            labelView.lineBreakMode = .byWordWrapping
            labelView.numberOfLines = 0
            labelView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            
            addSubview(textView)
            addSubview(labelView)
            
            textView.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(labelView)
            }
            labelView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        func setupSubviewsVisibility() {
            labelView.isHidden = isEditing
            textView.isHidden = !isEditing
        }
        
        func setupFonts() {
            textView.font = font
            labelView.font = font
        }
        
        func setDelegate(_ delegate: UITextViewDelegate) {
            textView.delegate = delegate
        }
        
        override func becomeFirstResponder() -> Bool {
            textView.becomeFirstResponder()
        }
        
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            textView.sizeThatFits(size)
        }
        
        override func resignFirstResponder() -> Bool {
            textView.resignFirstResponder()
        }
    }
    
    
    
    class Coordinator: NSObject, UITextViewDelegate {

        @Binding var text: String
        @Binding var isEditing: Bool
        var didBecomeFirstResponder = false

        init(text: Binding<String>, isEditing: Binding<Bool>) {
            _text = text
            _isEditing = isEditing
        }

        func textViewDidChange(_ textView: UITextView) {
            text = textView.text ?? ""
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.isEditing = false
            }
        }
    }
    
    @Binding var text: String
    let placeholder: String
    let font: Font.Chcklst
    let color: Color
    @Binding var isEditing: Bool
    @Binding var isCrossedOut: Bool
    @Binding var desiredHeight: CGFloat
    
    func makeUIView(context: Context) -> ChecklistItemUITextView {
        let textView = ChecklistItemUITextView(isEditing: isEditing, placeholder: placeholder)
        textView.font = font.uiFont
        textView.textColor = color.toUIColor()
        textView.setDelegate(context.coordinator)
        return textView
    }
    
    func updateUIView(_ uiView: ChecklistItemUITextView, context: Context) {
        uiView.attributedText = nil
        uiView.text = text
        if isCrossedOut {
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: text)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            uiView.attributedText = attributeString
        }
        uiView.isEditing = isEditing
        if isEditing && !context.coordinator.didBecomeFirstResponder {
            _ = uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        } else if !isEditing && context.coordinator.didBecomeFirstResponder {
            _ = uiView.resignFirstResponder()
            context.coordinator.didBecomeFirstResponder = false
        }
       let fixedWidth = uiView.frame.size.width
       let newSize = uiView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))

       DispatchQueue.main.async {
           self.desiredHeight = newSize.height
       }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, isEditing: $isEditing)
    }
}

struct MultilineTextView_Previews: PreviewProvider {
    static var previews: some View {
        MultilineTextView(
            text: .constant(""),
            placeholder: "Add task",
            font: Modifier.Checklist.Item.font,
            color: Modifier.Checklist.Item.color,
            isEditing: .constant(false),
            isCrossedOut: .constant(false),
            desiredHeight: .constant(20)
        )
    }
}
