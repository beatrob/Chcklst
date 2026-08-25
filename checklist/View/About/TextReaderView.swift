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
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    Text(viewModel.text)
                        .modifier(Modifier.Checklist.Description())
                        .padding()
                }
            }
            .background(Color.mainBackground)
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close")
                }
            }
            .chcklstNavigationBar()
        }
    }
}

struct TextReaderView_Previews: PreviewProvider {
    static var previews: some View {
        TextReaderView(
            viewModel: .init(title: "Something", text: "Something text", isBackButtonHidden: false)
        )
    }
}
