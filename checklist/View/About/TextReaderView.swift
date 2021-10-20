//
//  TextReaderView.swift
//  checklist
//
//  Created by Robert Konczi on 9/27/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct TextReaderView: View {
    
    @StateObject var viewModel: TextReaderViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            BackButtonNavBar(viewModel: viewModel.navbarViewModel)
            ScrollView {
                Text(viewModel.text)
                    .modifier(Modifier.Checklist.Description())
                    .padding()
            }
        }
        .navigationBarHidden(true)
        .background(Color.mainBackground)
    }
}

struct TextReaderView_Previews: PreviewProvider {
    static var previews: some View {
        TextReaderView(
            viewModel: .init(title: "Something", text: "Something text", isBackButtonHidden: false)
        )
    }
}
