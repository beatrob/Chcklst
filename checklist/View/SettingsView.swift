//
//  SettingsView.swift
//  checklist
//
//  Created by Róbert Konczi on 23/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(
                destination: viewModel.viewToNavigate,
                isActive: $viewModel.isViewToNavigateVisible,
                label: { EmptyView() }
            )
            HStack {
                Button("My templates") {
                    self.viewModel.onMyTemplates.send()
                }
                Spacer()
            }
            .padding()
            Spacer()
        }
        .navigationBarTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel())
    }
}
