//
//  AboutView.swift
//  checklist
//
//  Created by Robert Konczi on 9/23/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    
    @ObservedObject var viewModel: AboutViewModel
    
    var body: some View {
        ZStack {
            Color.menuBackground.ignoresSafeArea()
            VStack {
                BackButtonNavBar(viewModel: viewModel.navbarViewModel)
                VStack {
                    Spacer()

                    Image("chcklst-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .padding(.vertical)
                    
                    Text("© 2021")
                        .modifier(Modifier.Checklist.Description())
                    Text("Robert Konczi")
                        .modifier(Modifier.Checklist.Description())
                        .padding(.bottom)
                    
                    
                }
            }
            .background(Color.mainBackground)
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView(
            viewModel: AboutViewModel()
        )
    }
}
