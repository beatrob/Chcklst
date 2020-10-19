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


struct ChecklistItemTextView: UIViewRepresentable {
    
    class ChecklistItemUITextView: UIView {
         
        private let textView = UITextView()
        private let labelView = UILabel()
        
        var font: UIFont = .systemFont(ofSize: 16) {
            didSet {
                setupFonts()
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
                labelView.text = text
            }
        }
        
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        init(isEditing: Bool) {
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
            isEditing = false
        }
    }
    
    @Binding var text: String
    @Binding var isEditing: Bool
    @Binding var desiredHeight: CGFloat
    
    func makeUIView(context: Context) -> ChecklistItemUITextView {
        let textView = ChecklistItemUITextView(isEditing: isEditing)
        textView.setDelegate(context.coordinator)
        return textView
    }
    
    func updateUIView(_ uiView: ChecklistItemUITextView, context: Context) {
        uiView.text = text
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

struct ChecklistItemTextView_Previews: PreviewProvider {
    static var previews: some View {
        ChecklistItemTextView(text: .constant("Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Integer imperdiet lectus quis justo. Vestibulum fermentum tortor id mi. Mauris tincidunt sem sed arcu. Maecenas aliquet accumsan leo. Cras elementum. In enim a arcu imperdiet malesuada. Aliquam ante. Sed convallis magna eu sem. Maecenas fermentum, sem in pharetra pellentesque, velit turpis volutpat ante, in pharetra metus odio a lectus. Curabitur bibendum justo non orci. Maecenas ipsum velit, consectetuer eu lobortis ut, dictum at dui. Duis sapien nunc, commodo et, interdum suscipit, sollicitudin et, dolor. Aliquam erat volutpat. Morbi leo mi, nonummy eget tristique non, rhoncus non leo. Sed convallis magna eu sem."), isEditing: .constant(false), desiredHeight: .constant(20))
    }
}
