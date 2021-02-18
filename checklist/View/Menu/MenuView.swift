//
//  MenuView.swift
//  checklist
//
//  Created by Róbert Konczi on 15.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    
    @ObservedObject var viewModel: MenuViewModel
    
    var body: some View {
        ZStack {
            Color.checklistBackground
            VStack {
                ForEach(viewModel.filterItems) { filterItem in
                    MenuItemView(viewModel: filterItem)
                }
                Spacer()
            }
            .ignoresSafeArea()
        }.ignoresSafeArea()
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(viewModel: MenuViewModel())
    }
}
