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
                case normal = 90
                case expanded = 145
            }
            
            func body(content: Content) -> some View {
                content
                    .frame(height: isExpanded ? Height.expanded.rawValue : Height.normal.rawValue)
                    .background(Color.menuBackground)
                    .ignoresSafeArea()
            }
        }
        
        struct Subtitle: ViewModifier {
            
            func body(content: Content) -> some View {
                content
                    .font(Font.Chcklst.item.font)
                    .foregroundColor(.firstAccent)
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
