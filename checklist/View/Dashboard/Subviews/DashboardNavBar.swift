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
    
    var navBar: some View {
        HStack(spacing: 15) {
            NavBarChipButton(viewModel: viewModel.menuButtonViewModel)
            Spacer()
            
            HStack(spacing: 5) {
                Image(systemName: "arrow.up.arrow.down")
                    .modifier(Modifier.Menu.Section())
                Text(viewModel.sortedByTitle)
                    .modifier(Modifier.Menu.Section())
            }
            
            if viewModel.isFilterVisible {
                HStack(spacing: 5) {
                    Image(systemName: "eye")
                        .modifier(Modifier.Menu.Section())
                    Text(viewModel.filterTitle)
                        .modifier(Modifier.Menu.Section())
                }
            }
            
            NavBarChipButton(viewModel: viewModel.searchButtonViewModel)
            NavBarChipButton(viewModel: viewModel.addButtonViewModel)
        }
    }
    
    var searchBar: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField(
                    "Search for title, description or item",
                    text: $viewModel.searchText) { didBegin in
                    viewModel.isSearchTitleVisible = !didBegin
                }
                .modifier(Modifier.NavBar.SearchTextField())
                
                Spacer()
                NavBarChipButton(viewModel: viewModel.closeSearchButtonViewModel)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                if viewModel.isSearchBarVisible {
                    searchBar
                } else {
                    navBar
                }
            }
            .padding(.bottom, 10)
            .padding(.horizontal)
        }
        .modifier(Modifier.NavBar.NavBar(isExpanded: viewModel.isSearchBarVisible)
        )
    }
}

struct DashboardNavigationBar_Previews: PreviewProvider {
    
    static let viewModel: DashboardNavBarViewModel = {
        let viewModel = DashboardNavBarViewModel()
        viewModel.isSearchBarVisible = true
        return viewModel
    }()
    
    static var previews: some View {
        Group {
            DashboardNavBar(
                viewModel: viewModel
            ).previewLayout(.fixed(width: 800, height: 80))
            DashboardNavBar(
                viewModel: viewModel
            ).preferredColorScheme(.dark).previewLayout(.fixed(width: 800, height: 100))
        }
    }
}
