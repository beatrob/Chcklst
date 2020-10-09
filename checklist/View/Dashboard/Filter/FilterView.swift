//
//  FilterView.swift
//  checklist
//
//  Created by Róbert Konczi on 09/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct FilterView: View {
    
    @ObservedObject var viewModel: FilterViewModel
    
    var body: some View {
        HStack {
            ForEach(viewModel.items) { item in
                Spacer()
                FilterItemView(
                    image: item.image,
                    isSelected: viewModel.selectedItem == item.filterItem,
                    onTapped: item.onTapped
                )
                Spacer()
            }
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(viewModel: .init(onSelectFilter: .init()))
    }
}
