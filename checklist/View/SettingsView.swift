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
    @EnvironmentObject var navigationHelper: NavigationHelper
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(
                destination: navigationHelper.settingsDestination,
                tag: .myTemplates,
                selection: $navigationHelper.settingsSelection
            ) {
                EmptyView()
            }
            .isDetailLink(false)
            .hidden()
            
            HStack {
                Button("My templates") {
                    self.viewModel.onMyTemplates.send()
                }
                Spacer()
            }
            .padding()
            Spacer()
        }
        .navigationBarTitle("Settings", displayMode: .large)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel(navigationHelper: NavigationHelper()))
    }
}
