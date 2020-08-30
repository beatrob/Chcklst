//
//  MyTemplatesView.swift
//  checklist
//
//  Created by Róbert Konczi on 30/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct MyTemplatesView: View {
    
    @ObservedObject var viewModel: MyTemplatesViewModel
    
    var body: some View {
        VStack {
            ForEach(
                viewModel.templates,
                id: \.id) { template in
                    MyTemplateItemView(
                        name: template.title,
                        description: template.description
                    )
            }
            Spacer()
        }
        .navigationBarTitle("My templates", displayMode: .large)
    }
}

struct MyTemplatesView_Previews: PreviewProvider {
    static var previews: some View {
        MyTemplatesView(
            viewModel: .init(
                templateDataSource: MockTemplateDataSource()
            )
        )
    }
}
