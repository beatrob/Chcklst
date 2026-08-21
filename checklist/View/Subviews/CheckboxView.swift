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
        Button {
            withAnimation {
                isChecked.toggle()
            }
        } label: {
            HStack {
                Image(systemName: isChecked ? "checkmark.square" : "square")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .modifier(Modifier.Checklist.Item(color: .text))
                Text(title)
                    .modifier(Modifier.Checklist.Item(color: .text))
            }
        }
        .buttonStyle(.plain)
    }
}

struct ObservableCheckboxView: View {

    @ObservedObject var viewModel: CheckboxViewModel

    var body: some View {
        CheckboxView(title: viewModel.title, isChecked: $viewModel.isChecked)
    }
}

struct CheckboxView_Previews: PreviewProvider {
    
    static var previews: some View {
        CheckboxView(
            title: "Some checkbox",
            isChecked: .constant(false)
        )
    }
}
