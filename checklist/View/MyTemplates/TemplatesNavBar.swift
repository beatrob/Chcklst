//
//  TemplatesNavBar.swift
//  checklist
//
//  Created by Róbert Konczi on 22.03.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct TemplatesNavBar: View {
    
    @StateObject var viewModel: TemplatesNavBarViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            ZStack {
                HStack(spacing: 15) {
                    NavBarChipButton(viewModel: viewModel.backButton)
                    Spacer()
                }
                Text("My templates").modifier(Modifier.Menu.Section())
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .modifier(Modifier.NavBar.NavBar())
    }
}

struct TemplatesNavBar_Previews: PreviewProvider {
    static var previews: some View {
        TemplatesNavBar(viewModel: .init())
    }
}
