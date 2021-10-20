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
            VStack(spacing: 0) {
                NavigationLink(
                    destination: viewModel.navigationLinkDestination,
                    isActive: $viewModel.isNavigationLinkActive,
                    label: { EmptyView() }
                ).hidden()
                
                BackButtonNavBar(viewModel: viewModel.navigationBarViewModel)
                
                ForEach(viewModel.items) { item in
                    Button {
                        viewModel.selection = item
                    } label: {
                        VStack(spacing: 0) {
                            HStack {
                                Text(item.title)
                                    .listRowBackground(Color.clear)
                                    .padding(.vertical)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            Rectangle()
                                .foregroundColor(Color.gray)
                                .frame(height: 1)
                        }
                    }
                    .padding()
                    .modifier(Modifier.Button.TableCell())
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
