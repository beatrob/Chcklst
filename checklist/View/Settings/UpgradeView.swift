//
//  UpgradeView.swift
//  checklist
//
//  Created by Robert Konczi on 7/17/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI
import ActivityIndicatorView

struct UpgradeView: View {
    
    @StateObject var viewModel: UpgradeViewModel
    
    var activityIndicatiorView: some View {
        VStack {
            Spacer()
            
            Spacer()
        }
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                Spacer()
                ActivityIndicatorView(isVisible: $viewModel.isLoading, type: .growingArc(.firstAccent))
                    .frame(width: 50, height: 50, alignment: .center)
                if viewModel.isPendingVisible {
                    Text("Waiting for approval ...")
                        .modifier(Modifier.Upgrade.Description())
                        .padding()
                    Spacer()
                } else {
                    Spacer()
                }
            } else if viewModel.isPurchaseSuccessVisible {
                Spacer()
                Text("Upgrade complete")
                    .modifier(Modifier.Upgrade.Title())
                    .padding()
                Text("Thank you for your purchase!\nEnjoy unlimited access to checklilsts, templates & schedules!🙂")
                    .modifier(Modifier.Upgrade.Description())
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
                Button("Close") { viewModel.onCancelTapped.send() }
                .modifier(Modifier.Button.SecondaryAction(minWidth: 200))
                .padding()
            } else {
                VStack(spacing: .zero) {
                    HStack {
                        Spacer()
                        VStack {
                            Text(viewModel.productTitle)
                                .modifier(Modifier.Upgrade.Title())
                                .padding()
                            Text(viewModel.price)
                                .modifier(Modifier.Upgrade.Price())
                                .padding()
                        }
                        Spacer()
                    }.background(Color.menuBackground)
                    ZStack {
                        Color.checklistBackground.ignoresSafeArea()
                        VStack {
                            Spacer()
                            Text("By upgrading you can unlock\nUNLIMITED ACCESS to")
                                .modifier(Modifier.Upgrade.Description())
                                .multilineTextAlignment(.center)
                                .padding()
                            getDescriptionItem(title: "Checklists")
                            getDescriptionItem(title: "Templates")
                            getDescriptionItem(title: "Schedules")
                            Spacer()
                        }
                    }
                }.ignoresSafeArea()
                Spacer()
                Button("Purchase") { viewModel.onPurchaseTapped.send() }
                .modifier(Modifier.Button.MainAction(minWidth: 200))
                .padding(.top)
                Button("Cancel") { viewModel.onCancelTapped.send() }
                .modifier(Modifier.Button.SecondaryAction(minWidth: 200))
                .padding()
            }
        }
        .onAppear {
            viewModel.onAppear.send()
        }
        .alert(isPresented: $viewModel.isAlertVisible) {
            viewModel.alert
        }
    }
    
    private func getDescriptionItem(title: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
            Text(title)
        }
        .modifier(Modifier.Upgrade.Description())
        .padding(.top)
    }
}

struct UpgradeView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = UpgradeViewModel(purchaseManager: MockPurchaseManager())
        viewModel.isLoading = false
        viewModel.loadMainProduct()
        return UpgradeView(viewModel: viewModel)
    }
}
