//
//  EditTemplateView.swift
//  checklist
//
//  Created by Róbert Konczi on 30/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct EditTemplateView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: EditTemplateViewModel
    
    var body: some View {
        if viewModel.shouldDismissView {
            presentationMode.wrappedValue.dismiss()
        }
        return VStack {
            TextField("Title", text: $viewModel.title)
            .font(.system(size: 38))
            .padding()
            TextField("Description", text: $viewModel.description)
            .font(.system(size: 12))
            .padding()
            ForEach(viewModel.items, id: \.id) { item in
                HStack {
                    Image(systemName: "circle")
                    TextField("TODO", text: item.$name)
                }
                .padding()
            }
            Button("Save") {
                self.viewModel.onSave.send()
            }.padding()
            Spacer()
        }
    }
}

struct EditTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        EditTemplateView(
            viewModel: .init(
                template: .init(
                    id: "",
                    title: "Template",
                    description: "Some template",
                    items: [
                    .init(id: "1", name: "Item 1", isDone: false, updateDate: Date())
                    ]
                ),
                updateTemplate: .init()
            )
        )
    }
}
