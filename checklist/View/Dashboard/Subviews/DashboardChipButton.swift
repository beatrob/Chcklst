//
//  FilterItemView.swift
//  checklist
//
//  Created by Róbert Konczi on 09/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct DashboardChipButton: View {
    
    @ObservedObject var viewModel: DashboardChipButtonViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            viewModel.icon.map { icon in
                icon
                    .modifier(Modifiers.Menu.LightItem())
            }
            viewModel.title.map { title in
                Text(title)
                    .modifier(Modifiers.Menu.LightItem())
                    
            }
        }
        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
        .overlay(
            Capsule()
                .stroke(Color.firstAccent)
        ).background(
            Capsule()
                .fill(Color.firstAccent)
        )
    }
}

struct FilterItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DashboardChipButton(
                viewModel: .init(title: "Some chip button", icon: Image(systemName: "plus"))
            ).previewLayout(.sizeThatFits)
            DashboardChipButton(
                viewModel: .init(title: "Some chip button", icon: Image(systemName: "plus"))
            ).preferredColorScheme(.dark).previewLayout(.sizeThatFits)
        }
    }
}
