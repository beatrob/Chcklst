//
//  SeparatorView.swift
//  checklist
//
//  Created by Robert Konczi on 4/15/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI


struct SeparatorView: View {
    
    var body: some View {
        Rectangle()
            .foregroundColor(.text)
            .opacity(0.5)
            .frame(height: 1)
            .padding()
    }
}
