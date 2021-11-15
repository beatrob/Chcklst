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
    @Published var isPendingVisible = false
    @Published var isAlertVisible = false
    @Published var isPurchaseSuccessVisible = false
    @Published var productTitle = ""
    @Published var price: LocalizedStringKey = ""
    let onAppear = EmptySubject()
    let onCancelTapped = EmptySubject()
    let onPurchaseTapped = EmptySubject()
    let onPurchaseSuccess: EmptyPublisher
    
    var alert: Alert = .empty
    private let purchaseManager: PurchaseManager
    private var cancellables = Set<AnyCancellable>()
    private var mainProduct: ProductDataModel?
    
    init(purchaseManager: PurchaseManager) {
        self.purchaseManager = purchaseManager
        self.onPurchaseSuccess = purchaseManager.mainProductPurchaseState
            .filter { $0 == .purchased }
            .map { _ in () }
            .eraseToAnyPublisher()
        
        purchaseManager.mainProductPurchaseState.sink { [weak self] state in
            self?.updatePurchaseState(state)
        }.store(in: &cancellables)
       
        onAppear.combineLatest(purchaseManager.mainProductPurchaseState).sink { [weak self] (_, state) in
            switch state {
            case .notPurchased, .unknown:
                self?.loadMainProduct()
            default:
                break
            }
        }.store(in: &cancellables)
    
        onPurchaseTapped.sink { [weak self] in
            guard let product = self?.mainProduct else {
                return
            }
            self?.purchaseProduct(product)
        }.store(in: &cancellables)
    }
    
    func loadMainProduct() {
        Task {
            let result = await purchaseManager.getMainProduct()
            await MainActor.run {
                withAnimation {
                    isLoading = false
                }
                switch result {
                case .success(let product):
                    self.mainProduct = product
                    self.productTitle = product.title
                    self.price = "Upgrade for\n**\(product.localizedPrice)**"
                case .failure(let error):
                    error.log(message: "Failed to load purchase")
                    self.showAlert(error: error)
                }
            }
        }
    }
    
    func purchaseProduct(_ product: ProductDataModel) {
        Task {
            let result = await purchaseManager.purchaseProduct(product)
            await MainActor.run {
                switch result {
                case .success:
                    break // state handled publisher
                case .failure(let error):
                    isLoading = false
                    self.showAlert(error: error)
                }
            }
        }
    }
    
    private func showAlert(error: Error) {
        self.alert = Alert.init(title: Text(error.localizedDescription))
        self.isAlertVisible = true
    }
    
    private func updatePurchaseState(_ state: PurchaseSate) {
        withAnimation {
            switch state {
            case .purchased:
                isPurchaseSuccessVisible = true
                isPendingVisible = false
                isLoading = false
            case .pending:
                isPendingVisible = true
                isPurchaseSuccessVisible = false
                isLoading = true
            case .unknown, .notPurchased:
                isPendingVisible = false
                isPurchaseSuccessVisible = false
                isLoading = false
            case .inProgress:
                isPendingVisible = false
                isPurchaseSuccessVisible = false
                isLoading = true
            }
        }
    }
}
