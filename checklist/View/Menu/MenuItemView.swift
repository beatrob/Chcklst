//
//  MenuItemView.swift
//  checklist
//
//  Created by Róbert Konczi on 15.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct MenuItemView<Item: Identifiable>: View {
    
    @ObservedObject var viewModel: MenuItemViewModel<Item>
    
    var body: some View {
        HStack {
            Text(viewModel.title)
                .modifier(
                    Modifiers.Menu.Item(color: .firstAccent)
                )
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .onTapGesture {
                    viewModel.onSelect.send()
                }
            
        }.background(
            Capsule()
                .fill(viewModel.isSelected ? Color.menuBackground : Color.clear)
        )
    }
}

struct MenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = MenuItemViewModel(dataModel: SortDataModel.latest, isSelected: false)
        return MenuItemView(viewModel: viewModel)
            .previewLayout(.sizeThatFits)
    }
}
