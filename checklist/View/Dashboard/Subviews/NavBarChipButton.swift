//
//  FilterItemView.swift
//  checklist
//
//  Created by Róbert Konczi on 09/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct NavBarChipButton: View {
    
    @ObservedObject var viewModel: NavBarChipButtonViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            viewModel.icon.map { icon in
                icon
                    .modifier(Modifier.Menu.LightItem())
            }
            viewModel.title.map { title in
                Text(title)
                    .modifier(Modifier.Menu.LightItem())
                    
            }
        }
        .frame(
            width: viewModel.isOnlyIcon ? 30 : nil,
            height: 30
        )
        .padding(.horizontal, viewModel.isOnlyIcon ? 0 : 5 )
        .overlay(
            Capsule()
                .stroke(Color.firstAccent)
        ).background(
            Capsule()
                .fill(Color.firstAccent)
        )
        .onTapGesture {
            viewModel.didTapSubject.send()
        }
    }
}

struct FilterItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavBarChipButton(
                viewModel: .init(title: "Some chip button", icon: Image(systemName: "plus"))
            ).previewLayout(.sizeThatFits)
            NavBarChipButton(
                viewModel: .init(title: "Some chip button", icon: Image(systemName: "plus"))
            ).preferredColorScheme(.dark).previewLayout(.sizeThatFits)
            NavBarChipButton(
                viewModel: .init(title: nil, icon: Image(systemName: "plus"))
            ).preferredColorScheme(.dark).previewLayout(.sizeThatFits)
        }
    }
}
