//
//  ChecklistTitle.swift
//  checklist
//
//  Created by Róbert Konczi on 12.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI


struct ChecklistTitle: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color("textColor"))
            .font(Font.AppFont.checklistTitle.font)
    }
}
