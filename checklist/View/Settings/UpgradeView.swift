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
            ActivityIndicatorView(isVisible: $viewModel.isLoading, type: .growingArc(.firstAccent))
                .frame(width: 50, height: 50, alignment: .center)
            Spacer()
        }
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
               activityIndicatiorView
            } else {
                Text(viewModel.productTitle)
                    .modifier(Modifier.Upgrade.Title())
            }
        }
        .onAppear {
            viewModel.onAppear.send()
        }
        .alert(isPresented: $viewModel.isAlertVisible) {
            viewModel.alert
        }
    }
}

struct UpgradeView_Previews: PreviewProvider {
    static var previews: some View {
        UpgradeView(viewModel: .init(purchaseManager: MockPurchaseManager()))
    }
}
