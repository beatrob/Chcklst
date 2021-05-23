//
//  CheckboxView.swift
//  checklist
//
//  Created by Róbert Konczi on 04/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct CheckboxView: View {
    
    @StateObject var viewModel: CheckboxViewModel
    
    var body: some View {
        HStack {
            Image(systemName: viewModel.isChecked ? "checkmark.square" : "square")
                .resizable()
                .frame(width: 20, height: 20)
                .modifier(Modifier.Checklist.Item())
            Text(viewModel.title)
                .modifier(Modifier.Checklist.Item())
        }.onTapGesture {
            self.viewModel.isChecked.toggle()
        }
    }
}

struct CheckboxView_Previews: PreviewProvider {
    
    static var previews: some View {
        CheckboxView(
            viewModel: .init(title: "Some checkbox", isChecked: false)
        )
    }
}
