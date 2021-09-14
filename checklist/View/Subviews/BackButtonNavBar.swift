//
//  BackButtonNavBar.swift
//  checklist
//
//  Created by Robert Konczi on 5/5/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct BackButtonNavBar: View {
    
    @StateObject var viewModel: BackButtonNavBarViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                HStack(spacing: 15) {
                    NavBarChipButton(viewModel: viewModel.backButton)
                    Spacer()
                    viewModel.rightButton.map {
                        NavBarChipButton(viewModel: $0)
                    }
                }
                Text(viewModel.title).modifier(Modifier.Menu.Section())
            }
            .padding(.horizontal)
            .padding(.bottom, 7)
        }
        .modifier(Modifier.NavBar.NavBar(isExpanded: false))
    }
}

struct BackButtonNavBar_Previews: PreviewProvider {
    static var previews: some View {
        BackButtonNavBar(viewModel: .init(title: "Nav bar with back button"))
    }
}
