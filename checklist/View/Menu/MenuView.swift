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
            VStack(alignment: .center) {
                HStack {
                    Image("chcklst-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 45)
                        .padding(.leading)
                        .padding(.top, 45)
                        .padding(.bottom, 20)
                    Spacer()
                }
                HStack {
                    Image(systemName: "arrow.up.arrow.down")
                        .modifier(Modifiers.Menu.Section())
                        .padding(.leading)
                    Text("Sort by")
                        .modifier(Modifiers.Menu.Section())
                    Spacer()
                }
                ForEach(viewModel.sortItems) { filterItem in
                    MenuItemView(viewModel: filterItem)
                }
                HStack {
                    Image(systemName: "eye")
                        .modifier(Modifiers.Menu.Section())
                        .padding(.leading)
                    Text("Filter by")
                        .modifier(Modifiers.Menu.Section())
                    Spacer()
                }
                .padding(.vertical)
                ForEach(viewModel.filterItems) { filterItem in
                    MenuItemView(viewModel: filterItem)
                }
                Spacer()
                HStack {
                    MenuItemView(viewModel: viewModel.myTemplates)
                        .padding(.leading)
                    Spacer()
                }
                HStack {
                    MenuItemView(viewModel: viewModel.settings)
                        .padding(.leading)
                    Spacer()
                }
                HStack {
                    MenuItemView(viewModel: viewModel.about)
                        .padding(.leading)
                    Spacer()
                }
                .padding(.bottom, 30)
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
