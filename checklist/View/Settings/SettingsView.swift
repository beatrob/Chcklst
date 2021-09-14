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
        ZStack {
            Color.menuBackground.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                BackButtonNavBar(viewModel: viewModel.navBarViewModel)
                //            NavigationLink(
                //                destination: navigationHelper.settingsDestination,
                //                tag: .myTemplates,
                //                selection: $navigationHelper.settingsSelection
                //            ) {
                //                EmptyView()
                //            }
                //            .isDetailLink(false)
                //            .hidden()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        if viewModel.isInAppEnabled {
                            Text("Chcklst+").modifier(Modifier.Settings.ItemTitle())
                                .padding()
                            if viewModel.isUpgradeComplete {
                                HStack {
                                    Spacer()
                                    Text("You're all set!\nThank you for using Chcklist! 🙂")
                                        .modifier(Modifier.Settings.ItemDescription())
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                }
                            } else {
                                HStack {
                                    Spacer()
                                    Button("Upgrade") {
                                        viewModel.onUpgradeTapped.send()
                                    }.modifier(Modifier.Button.MainAction())
                                    Spacer()
                                }
                                .padding(.bottom)
                                Text("Upgrade to CHCKLST+ to get unlimited checklists, templates & schedules.")
                                    .modifier(Modifier.Settings.ItemDescription())
                                    .padding(.horizontal)
                            }
                            SeparatorView()
                        }
                        
                        HStack {
                            Text("Appearance").modifier(Modifier.Settings.ItemTitle())
                                .padding()
                            Spacer()
                        }
                        Picker(selection: /*@START_MENU_TOKEN@*/.constant(1)/*@END_MENU_TOKEN@*/, label: Text(""), content: {
                            Text("Automatic").tag(1)
                            Text("Light").tag(2)
                            Text("Dark").tag(2)
                        })
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        SeparatorView()
                        
                        HStack {
                            Text("Notifications").modifier(Modifier.Settings.ItemTitle())
                                .padding()
                            Spacer()
                            Toggle("", isOn: .constant(true))
                                .toggleStyle(SwitchToggleStyle(tint: .firstAccent))
                                .padding()
                        }
                        Text("Enable push notifications to receive reminders and get notified when a scheduled checklist is ready.")
                            .modifier(Modifier.Settings.ItemDescription())
                            .padding(.horizontal)
                    }
                }
            }
            .background(Color.mainBackground)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.isSheetVisible) {
            viewModel.sheet
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsView(
                viewModel: SettingsViewModel(
                    navigationHelper: NavigationHelper(),
                    restrictionManager: MockRestrictionManager(),
                    purchaseManager: MockPurchaseManager()
                )
            )
            SettingsView(
                viewModel: SettingsViewModel(
                    navigationHelper: NavigationHelper(),
                    restrictionManager: MockRestrictionManager(),
                    purchaseManager: MockPurchaseManager()
                )
            )
            .preferredColorScheme(.dark)
        }
    }
}
