//
//  MenuModifiers.swift
//  checklist
//
//  Created by Róbert Konczi on 15.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI


extension Modifiers {
    
    enum Menu {
        
        struct Item: ViewModifier {
            
            func body(content: Content) -> some View {
                content
                    .font(Font.Chcklst.boldItem.font)
                    .foregroundColor(.firstAccent)
            }
        }
        
        struct LightItem: ViewModifier {
            
            func body(content: Content) -> some View {
                content
                    .font(Font.Chcklst.boldItem.font)
                    .foregroundColor(.lightText)
            }
        }
    }
}
