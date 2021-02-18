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
            
            func body(content: Content) -> some View {
                content
                    .foregroundColor(.text)
                    .font(Font.Chcklst.item.font)
            }
        }
        
        struct Title: ViewModifier {
            
            func body(content: Content) -> some View {
                content
                    .foregroundColor(.text)
                    .font(Font.Chcklst.title.font)
            }
        }
    }
}
