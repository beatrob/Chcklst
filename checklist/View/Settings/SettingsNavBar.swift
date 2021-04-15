//
//  SettingsNavBar.swift
//  checklist
//
//  Created by Robert Konczi on 4/15/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct SettingsNavBar: View {
    
    @StateObject var viewModel: SettingsNavBarViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            ZStack {
                HStack(spacing: 15) {
                    NavBarChipButton(viewModel: viewModel.backButton)
                    Spacer()
                }
                Text("Settings").modifier(Modifier.Menu.Section())
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .modifier(Modifier.NavBar.NavBar())
    }
}

struct SettingsNavBar_Previews: PreviewProvider {
    static var previews: some View {
        SettingsNavBar(viewModel: .init())
    }
}
