//
//  Modifier+Purchase.swift
//  checklist
//
//  Created by Robert Konczi on 7/18/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI


extension Modifier {
    
    enum Upgrade {
        
        struct Title: ViewModifier {
            
            func body(content: Content) -> some View {
                content
                    .foregroundColor(.firstAccent)
                    .font(.largeTitle)
            }
        }
    }
}
