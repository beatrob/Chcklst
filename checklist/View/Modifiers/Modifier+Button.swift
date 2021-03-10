//
//  ButtonModifiers.swift
//  checklist
//
//  Created by Róbert Konczi on 07.03.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI


extension Modifier {
    
    enum Button {
        
        struct MainAction: ViewModifier {
            
            func body(content: Content) -> some View {
                content
                    .font(Font.Chcklst.boldItem.font)
                    .foregroundColor(.lightText)
                    .frame(width: 150, height: 40)
                    .overlay(
                        Capsule()
                            .stroke(Color.firstAccent)
                    ).background(
                        Capsule()
                            .fill(Color.firstAccent)
                    )
            }
        }
    }
}
