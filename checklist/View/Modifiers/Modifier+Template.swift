//
//  Modifier+Template.swift
//  checklist
//
//  Created by Róbert Konczi on 22.03.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI


extension Modifier {
    
    enum Template {
        
        struct SmallTitle: ViewModifier {
            
            func body(content: Content) -> some View {
                content
                    .foregroundColor(.firstAccent)
                    .font(Font.Chcklst.smallTitle.font)
            }
        }
    }
}
