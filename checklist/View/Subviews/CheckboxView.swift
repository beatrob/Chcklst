//
//  CheckboxView.swift
//  checklist
//
//  Created by Róbert Konczi on 04/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct CheckboxView: View {
    
    let title: String
    @Binding var isChecked: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isChecked ? "checkmark.square" : "square")
                .resizable()
                .frame(width: 20, height: 20)
                .modifier(Modifier.Checklist.Item())
            Text(title)
                .modifier(Modifier.Checklist.Item())
        }.onTapGesture {
            self.isChecked.toggle()
        }
    }
}

struct CheckboxView_Previews: PreviewProvider {
    
    static var previews: some View {
        CheckboxView(title: "Some checkbox", isChecked: .init(get: { false }, set: { _ in }))
    }
}
