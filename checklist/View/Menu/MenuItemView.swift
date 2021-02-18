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
        Text(viewModel.title)
            .modifier(Modifiers.Menu.Item())
            .padding()
    }
}

struct MenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = MenuItemViewModel(dataModel: FilterItemData.latest)
        return MenuItemView(viewModel: viewModel)
            .previewLayout(.sizeThatFits)
    }
}
