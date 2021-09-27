//
//  TextReaderView.swift
//  checklist
//
//  Created by Robert Konczi on 9/27/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct TextReaderView: View {
    
    let viewModel: TextReaderViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                Text(viewModel.title)
                    .modifier(Modifier.Checklist.BigTitle())
                    .padding()
                Text(viewModel.text)
                    .modifier(Modifier.Checklist.Description())
                    .padding()
            }
        }
        .background(Color.mainBackground)
    }
}

struct TextReaderView_Previews: PreviewProvider {
    static var previews: some View {
        TextReaderView(viewModel: .init(title: "Something", text: "Something text"))
    }
}
