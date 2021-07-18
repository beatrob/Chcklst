//
//  UpgradeViewModel.swift
//  checklist
//
//  Created by Robert Konczi on 7/17/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI
import Combine


class UpgradeViewModel: ObservableObject {
    
    @Published var isLoading = true
    @Published var isAlertVisible = false
    @Published var productTitle: String = ""
    let onAppear = EmptySubject()
    var alert: Alert = .empty
    private let purchaseManager: PurchaseManager
    private var cancellables = Set<AnyCancellable>()
    
    init(purchaseManager: PurchaseManager) {
        self.purchaseManager = purchaseManager
        onAppear.sink { [weak self] in
            guard let self = self else {
                return
            }
            purchaseManager.getMainProduct().done { product in
                self.productTitle = product.title
            }.ensure {
                self.isLoading = false
            }
            .catch { error in
                error.log(message: "Failed to load purchase")
                self.alert = Alert.init(title: Text(error.localizedDescription))
                self.isAlertVisible = true
            }
        }.store(in: &cancellables)
    }
}
