//
//  DashboardNavigationBar.swift
//  checklist
//
//  Created by Róbert Konczi on 18.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct DashboardNavBar: View {
    
    @StateObject var viewModel: DashboardNavBarViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            HStack(spacing: 15) {
                DashboardChipButton(viewModel: viewModel.menuButtonViewModel)
                Spacer()
                
                HStack(spacing: 5) {
                    Image(systemName: "arrow.up.arrow.down")
                        .modifier(Modifiers.Menu.Section())
                    Text(viewModel.sortedByTitle)
                        .modifier(Modifiers.Menu.Section())
                }
                
                if viewModel.isFilterVisible {
                    HStack(spacing: 5) {
                        Image(systemName: "eye")
                            .modifier(Modifiers.Menu.Section())
                        Text(viewModel.filterTitle)
                            .modifier(Modifiers.Menu.Section())
                    }
                }
                
                DashboardChipButton(viewModel: viewModel.searchButtonViewModel)
                DashboardChipButton(viewModel: viewModel.addButtonViewModel)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.menuBackground)
    }
}

struct DashboardNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DashboardNavBar(
                viewModel: .init()
            ).previewLayout(.fixed(width: 800, height: 80))
            DashboardNavBar(
                viewModel: .init()
            ).preferredColorScheme(.dark).previewLayout(.fixed(width: 800, height: 100))
        }
    }
}
