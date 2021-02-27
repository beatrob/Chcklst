//
//  NavBarModifier.swift
//  checklist
//
//  Created by Róbert Konczi on 27.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI


extension Modifiers {
    
    struct NavBar: ViewModifier {
        func body(content: Content) -> some View {
            content
                .frame(height: 90)
                .background(Color.menuBackground)
                .ignoresSafeArea()
        }
    }
}
