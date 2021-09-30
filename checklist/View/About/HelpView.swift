//
//  HelpView.swift
//  checklist
//
//  Created by Robert Konczi on 9/30/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct HelpView: View {
    
    @ObservedObject var viewModel: HelpViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(
                    destination: viewModel.navigationLinkDestination,
                    isActive: $viewModel.isNavigationLinkActive,
                    label: { EmptyView() }
                ).hidden()
                
                Text(LocalizedStringKey("help_title"))
                    .modifier(Modifier.Checklist.BigTitle())
                    .padding()
                ForEach(viewModel.items) { item in
                    HStack {
                    Text(item.title)
                        .modifier(Modifier.Checklist.SmallTitle())
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .modifier(Modifier.Checklist.SmallTitle())
                    }
                    .padding(.horizontal)
                    .onTapGesture {
                        viewModel.didSelectItem.send(item)
                    }
                    SeparatorView()
                }
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView(viewModel: .init())
    }
}
