//
//  MenuModifiers.swift
//  checklist
//
//  Created by Róbert Konczi on 15.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI


extension Modifier {
    
    enum Menu {
        
        struct Section: ViewModifier {
            
            func body(content: Content) -> some View {
                content
                    .lineLimit(1)
                    .font(Font.Chcklst.item.font)
                    .foregroundColor(.firstAccent)
            }
        }
        
        struct Item: ViewModifier {
            
            var color: Color
            
            func body(content: Content) -> some View {
                content
                    .font(Font.Chcklst.boldItem.font)
                    .foregroundColor(color)
            }
        }
        
        struct SelectedItem: ViewModifier {
            
            func body(content: Content) -> some View {
                content
                    .font(Font.Chcklst.boldItem.font)
                    .foregroundColor(.menuBackground)
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
