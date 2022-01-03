//
//  BackButtonNavBar.swift
//  checklist
//
//  Created by Robert Konczi on 5/5/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct BackButtonNavBar: View {
    
    private let bottomPadding: CGFloat = 10
    @StateObject var viewModel: BackButtonNavBarViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                HStack(spacing: 15) {
                    if !viewModel.isBackButtonHidden {
                        NavBarChipButton(viewModel: viewModel.backButton)
                    }
                    Spacer()
                    viewModel.rightButton.map {
                        NavBarChipButton(viewModel: $0)
                    }
                }
                Text(viewModel.title)
                    .modifier(Modifier.NavBar.Title(isBig: viewModel.style.isBig))
            }
            .if(viewModel.style.isBig || viewModel.topPaddingEnabled) { $0.padding(.top, bottomPadding) }
            .padding(.horizontal)
            .padding(.top, 5)
            .padding(.bottom, bottomPadding)
        }
        .modifier(Modifier.NavBar.NavBar(isTransparent: viewModel.isTransparent))
        .if(viewModel.isTransparent) { $0.background(Color.clear) }
    }
}

struct BackButtonNavBar_Previews: PreviewProvider {
    static var previews: some View {
        BackButtonNavBar(viewModel: .init(title: "Nav bar with back button"))
    }
}
