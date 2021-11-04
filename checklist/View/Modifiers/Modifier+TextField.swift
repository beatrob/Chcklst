//
//  Modifier+TextField.swift
//  checklist
//
//  Created by Robert Konczi on 4/18/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI


extension Modifier {
    
    enum TextField {

        struct Text: ViewModifier {
            
            let font: Font.Chcklst
            let isInPlaceholderMode: Bool
            
            init(font: Font.Chcklst? = nil, isInPlaceholderMode: Bool) {
                self.font = font ?? .description
                self.isInPlaceholderMode = isInPlaceholderMode
            }
            
            func body(content: Content) -> some View {
                content
                    .font(font.font)
                    .foregroundColor(isInPlaceholderMode ? Color.gray : Color.text)
            }
        }
        
        struct Placeholder: ViewModifier {
            
            let font: Font.Chcklst
            
            init(font: Font.Chcklst? = nil) {
                self.font = font ?? .description
            }
            
            func body(content: Content) -> some View {
                content
                    .font(font.font)
                    .foregroundColor(Color.gray)
            }
        }
    }
}
