//
//  Modifier+Settings.swift
//  checklist
//
//  Created by Robert Konczi on 4/15/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

extension Modifier {
    
    enum Settings {
        
        struct ItemTitle: ViewModifier {
            
            func body(content: Content) -> some View {
                content
                    .foregroundColor(.text)
                    .font(Font.Chcklst.smallTitle.font)
            }
        }
        
        struct ItemDescription: ViewModifier {
            
            func body(content: Content) -> some View {
                content
                    .foregroundColor(.text)
                    .font(Font.Chcklst.description.font)
            }
        }
    }
}
