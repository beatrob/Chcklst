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
        
        //MARK:-
        struct MainAction: ViewModifier {
            
            let minWidth: CGFloat
            
            init() {
                self.minWidth = 150
            }
            
            init(minWidth: CGFloat) {
                self.minWidth = minWidth
            }
            
            func body(content: Content) -> some View {
                content
                    .font(Font.Chcklst.boldItem.font)
                    .foregroundColor(.lightText)
                    .frame(minWidth: minWidth)
                    .frame(height: 40)
                    .overlay(
                        Capsule()
                            .stroke(Color.firstAccent)
                    ).background(
                        Capsule()
                            .fill(Color.firstAccent)
                    )
            }
        }
        
        //MARK:-
        struct SecondaryAction: ViewModifier {
            
            let minWidth: CGFloat
            
            init() {
                self.minWidth = 150
            }
            
            init(minWidth: CGFloat) {
                self.minWidth = minWidth
            }
            
            func body(content: Content) -> some View {
                content
                    .font(Font.Chcklst.boldItem.font)
                    .foregroundColor(.lightText)
                    .frame(minWidth: minWidth)
                    .frame(height: 40)
                    .overlay(
                        Capsule()
                            .stroke(Color.text)
                    ).background(
                        Capsule()
                            .fill(Color.text)
                    )
            }
        }
        
        //MARK:-
        struct DestructiveAction: ViewModifier {
            
            func body(content: Content) -> some View {
                content
                    .font(Font.Chcklst.description.font)
                    .foregroundColor(.red)
            }
        }
    }
}
