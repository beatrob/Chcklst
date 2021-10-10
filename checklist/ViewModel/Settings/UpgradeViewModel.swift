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
    @Published var isPurchaseSuccessVisible = false
    @Published var productTitle = ""
    @Published var price = ""
    let onAppear = EmptySubject()
    let onCancelTapped = EmptySubject()
    let onPurchaseTapped = EmptySubject()
    let onRestoreTapped = EmptySubject()
    let onPurchaseSuccess: EmptyPublisher
    
    var alert: Alert = .empty
    private let purchaseManager: PurchaseManager
    private var cancellables = Set<AnyCancellable>()
    private var mainProduct: ProductDataModel?
    
    init(purchaseManager: PurchaseManager) {
        self.purchaseManager = purchaseManager
        self.onPurchaseSuccess = purchaseManager.mainProductPurchasedPublisher
            .scan(false) { prev, next in prev != next && next }
            .map { _ in () }
            .eraseToAnyPublisher()
       
        onAppear.sink { [weak self] in
            self?.loadMainProduct()
        }.store(in: &cancellables)
    
        onPurchaseTapped.sink { [weak self] in
            guard let product = self?.mainProduct else {
                return
            }
            withAnimation {
                self?.isLoading = true
            }
            purchaseManager.purchaseProduct(product).done {
                withAnimation {
                    self?.isLoading = false
                    self?.isPurchaseSuccessVisible = true
                }
            }.catch { error in
                error.log(message: "Failed to purchase product")
                self?.showAlert(error: error)
                self?.isLoading = false
            }
        }.store(in: &cancellables)
        
        onRestoreTapped.sink { [weak self] in
            withAnimation {
                self?.isLoading = true
            }
            purchaseManager.restorePurchase().done {
                withAnimation {
                    self?.isLoading = false
                    self?.isPurchaseSuccessVisible = true
                }
            }.catch { error in
                error.log(message: "Failed to restore purchase")
                self?.showAlert(error: error)
                self?.isLoading = false
            }
        }.store(in: &cancellables)
    }
    
    func loadMainProduct() {
        purchaseManager.getMainProduct().done { product in
            self.mainProduct = product
            self.productTitle = product.title
            self.price = "Upgrade for \(product.localizedPrice)"
        }.ensure {
            withAnimation {
                self.isLoading = false
            }
        }
        .catch { error in
            error.log(message: "Failed to load purchase")
            self.showAlert(error: error)
        }
    }
    
    private func showAlert(error: Error) {
        self.alert = Alert.init(title: Text(error.localizedDescription))
        self.isAlertVisible = true
    }
}
