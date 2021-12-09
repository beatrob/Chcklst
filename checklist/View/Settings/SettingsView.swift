//
//  SettingsView.swift
//  checklist
//
//  Created by Róbert Konczi on 23/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI
import ActivityIndicatorView

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
                        
                        HStack {
                            Text("Appearance").modifier(Modifier.Settings.ItemTitle())
                            Spacer()
                        }
                        .padding()
                        Picker(selection: $viewModel.apperance, label: Text(""), content: {
                            Text(Appearance.automatic.rawValue).tag(Appearance.automatic)
                            Text(Appearance.light.rawValue).tag(Appearance.light)
                            Text(Appearance.dark.rawValue).tag(Appearance.dark)
                        })
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .padding(.bottom)
                        
                        SeparatorView()
                        
                        HStack {
                            Text("Notifications").modifier(Modifier.Settings.ItemTitle())
                                .padding(.bottom)
                                .padding(.leading)
                            Spacer()
                            Toggle("", isOn: $viewModel.notificationsEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: .firstAccent))
                                .padding()
                        }
                        Text("Enable push notifications to receive reminders and get notified when a scheduled checklist is ready.")
                            .modifier(Modifier.Settings.ItemDescription())
                            .padding(.horizontal)
                            .padding(.bottom)
                        
                        SeparatorView()
                        
                        if viewModel.isInAppEnabled {
                            Text("Chcklst+").modifier(Modifier.Settings.ItemTitle())
                                .padding(.vertical)
                                .padding(.leading)
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
                                    VStack(spacing: 0) {
                                        CapsuleButton(
                                            title: "Upgrade",
                                            type: .primary,
                                            onTapSubject: viewModel.onUpgradeTapped
                                        )
                                    }
                                    Spacer()
                                }
                                .padding(.bottom)
                                Text("Upgrade to CHCKLST+ to get unlimited checklists, templates & schedules.")
                                    .modifier(Modifier.Settings.ItemDescription())
                                    .padding(.horizontal)
                                HStack {
                                    Spacer()
                                    Button.init("Restore Purchase") {
                                        viewModel.onRestoreTapped.send()
                                    }
                                    .buttonStyle(.plain)
                                    .modifier(Modifier.Button.MinorAction())
                                    ActivityIndicatorView(
                                        isVisible: $viewModel.isRestoreInProgress,
                                        type: .growingArc(.firstAccent)
                                    )
                                        .frame(width: 20, height: 20, alignment: .center)
                                    Spacer()
                                }.padding(.vertical)
                            }
                        }
                    }
                }
            }
            .background(Color.mainBackground)
        }
        .onAppear { viewModel.onViewAppear.send() }
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.isSheetVisible) {
            viewModel.sheet
        }
        .alert(isPresented: $viewModel.isAlertVisible) {
            viewModel.alert
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
                    purchaseManager: MockPurchaseManager(),
                    appearanceManager: AppearanceManager(),
                    notificationManager: NotificationManager(checklistDataSource: MockChecklistDataSource())
                )
            )
            SettingsView(
                viewModel: SettingsViewModel(
                    navigationHelper: NavigationHelper(),
                    restrictionManager: MockRestrictionManager(),
                    purchaseManager: MockPurchaseManager(),
                    appearanceManager: AppearanceManager(),
                    notificationManager: NotificationManager(checklistDataSource: MockChecklistDataSource())
                )
            )
            .preferredColorScheme(.dark)
        }
    }
}
