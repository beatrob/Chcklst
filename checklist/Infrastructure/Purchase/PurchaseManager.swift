//
//  PurchaseManager.swift
//  checklist
//
//  Created by Robert Konczi on 7/1/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import PromiseKit
import Combine

protocol PurchaseManager {
    var isPurchaseEnabled: Bool { get }
    var mainProductPurchasedPublisher: AnyPublisher<Bool, Never> { get }
    func completeTransactions()
    func getMainProduct() -> Promise<ProductDataModel>
    func purchaseProduct(_ product: ProductDataModel) -> Promise<Void>
    func restorePurchase() -> Promise<Void>
}

class PurchaseManagerImpl: PurchaseManager {
    
    enum PurchaseError: LocalizedError {
        
        case retrieveFailed
        case productError
        case purchaseFailed
        case restoreFailed
        case nothingToRestore
        
        var errorDescription: String? {
            switch self {
            case .retrieveFailed:
                return "Laoding failed, try again later"
            case .productError:
                return "Something went wrong, try again later"
            case .purchaseFailed:
                return "Purchase failed, try again later"
            case .restoreFailed:
                return "Restore purchase failed, try again later"
            case .nothingToRestore:
                return "No previous purchase found"
            }
        }
    }
    
    private static let mainProductId = "com.robertkonczi.checklist.plus"
    private static let purchaseKey = "kPurchaseKey"
    private let mainProductPuchasedSubject = CurrentValueSubject<Bool, Never>(
        UserDefaults.standard.bool(forKey: PurchaseManagerImpl.purchaseKey)
    )
    private var cancellables = Set<AnyCancellable>()
    
    var isPurchaseEnabled: Bool {
        Bundle.main.restrictionsEnabled
    }
    
    let mainProductPurchasedPublisher: AnyPublisher<Bool, Never>
    
    init() {
        mainProductPurchasedPublisher = mainProductPuchasedSubject.eraseToAnyPublisher()
        mainProductPurchasedPublisher.dropFirst().sink { isPurchased in
            UserDefaults.standard.set(isPurchased, forKey: Self.purchaseKey)
        }.store(in: &cancellables)
    }
    
    func completeTransactions() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                default:
                    break
                }
            }
        }
    }
    
    func getMainProduct() -> Promise<ProductDataModel> {
        Promise { resolver in
            SwiftyStoreKit.retrieveProductsInfo([Self.mainProductId]) { result in
                guard
                    let product = result.retrievedProducts.first,
                    result.error == nil,
                    result.invalidProductIDs.isEmpty
                else {
                    result.error?.log(message: "Failed to retrieve product \(Self.mainProductId)")
                    resolver.reject(PurchaseError.retrieveFailed)
                    return
                }
                guard let dataModel = ProductDataModel(product: product) else {
                    resolver.reject(PurchaseError.productError)
                    return
                }
                resolver.fulfill(dataModel)
            }
        }
    }
    
    func purchaseProduct(_ product: ProductDataModel) -> Promise<Void> {
        Promise { resolver in
            SwiftyStoreKit.purchaseProduct(product.id) { result in
                switch result {
                case .success:
                    self.mainProductPuchasedSubject.send(true)
                    resolver.fulfill(())
                case .error(let error):
                    error.log(message: "Puchase failed")
                    resolver.reject(PurchaseError.purchaseFailed)
                }
            }
        }
    }
    
    func restorePurchase() -> Promise<Void> {
        Promise { resolver in
            SwiftyStoreKit.restorePurchases { results in
                if !results.restoreFailedPurchases.isEmpty {
                    resolver.reject(PurchaseError.restoreFailed)
                } else if !results.restoredPurchases.isEmpty {
                    resolver.fulfill(())
                } else {
                    resolver.reject(PurchaseError.nothingToRestore)
                }
            }
        }
    }
}
