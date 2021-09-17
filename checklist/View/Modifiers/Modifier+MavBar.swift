//
//  NavBarModifier.swift
//  checklist
//
//  Created by Róbert Konczi on 27.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI


extension Modifier {
    
    enum NavBar {
        
        struct NavBar: ViewModifier {
            
            let isExpanded: Bool
            
            enum Height: CGFloat {
                case normal = 58 // 90
                case expanded = 145
            }
            
            func body(content: Content) -> some View {
                content
                    .background(Color.menuBackground)
            }
        }
        
        struct Subtitle: ViewModifier {
            
            func body(content: Content) -> some View {
                content
                    .font(Font.Chcklst.item.font)
                    .foregroundColor(.firstAccent)
            }
        }
        
        struct SearchTextField: ViewModifier {
            
            func body(content: Content) -> some View {
                content
                    .font(Font.Chcklst.item.font)
                    .foregroundColor(.firstAccent)
                    .padding(.horizontal)
                    .overlay(Capsule().stroke(Color.firstAccent))
            }
        }
        
        struct Title: ViewModifier {
            
            func body(content: Content) -> some View {
                content
                    .font(Font.Chcklst.smallTitle.font)
                    .foregroundColor(.firstAccent)
            }
        }
    }
}
