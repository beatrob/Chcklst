//
//  ChecklistModifiers.swift
//  checklist
//
//  Created by Róbert Konczi on 15.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI


extension Modifiers {
    
    enum Checklist {

        struct Item: ViewModifier {
            
            static var color = Color.text
            static var font = Font.Chcklst.item
            
            func body(content: Content) -> some View {
                content
                    .foregroundColor(.text)
                    .font(Font.Chcklst.item.font)
            }
        }
        
        struct SmallTitle: ViewModifier {
            
            func body(content: Content) -> some View {
                content
                    .foregroundColor(.text)
                    .font(Font.Chcklst.smallTitle.font)
            }
        }
        
        struct BigTitle: ViewModifier {
            
            static var color = Color.text
            static var font = Font.Chcklst.bigTitle
            
            func body(content: Content) -> some View {
                content
                    .foregroundColor(Self.color)
                    .font(Self.font.font)
            }
        }
        
        struct Description: ViewModifier {
            
            static var color = Color.text
            static var font = Font.Chcklst.description
            
            func body(content: Content) -> some View {
                content
                    .foregroundColor(Self.color)
                    .font(Self.font.font)
            }
        }
        
        struct TextField: ViewModifier {
            
            let isEditable: Bool
            
            func body(content: Content) -> some View {
                content
                    .padding(5)
                    .border(Color.text, width: isEditable ? 0.5 : 0)
                    .padding()
            }
        }
    }
}
