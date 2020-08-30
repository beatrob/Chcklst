//
//  EditTemplateView.swift
//  checklist
//
//  Created by Róbert Konczi on 30/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct EditTemplateView: View {
    
    @ObservedObject var viewModel: EditTemplateViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct EditTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        EditTemplateView(
            viewModel: .init(template: .init(nil))
        )
    }
}
