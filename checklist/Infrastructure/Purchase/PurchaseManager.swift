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

protocol PurchaseManager {
    var isPurchaseEnabled: Bool { get }
    var isMainProductPurchased: Bool { get }
    func completeTransactions()
    func getMainProduct() -> Promise<ProductDataModel>
    func purchaseProduct(_ product: ProductDataModel) -> Promise<Void>
}

class PurchaseManagerImpl: PurchaseManager {
    
    enum PurchaseError: LocalizedError {
        
        case retrieveFailed
        case productError
        case purchaseFailed
        
        var errorDescription: String? {
            switch self {
            case .retrieveFailed:
                return "Laoding failed, try again later"
            case .productError:
                return "Something went wrong, try again later"
            case .purchaseFailed:
                return "Purchase failed, try again later"
            }
        }
    }
    
    private let mainProductId = "com.robertkonczi.checklist.plus"
    private let purchaseKey = "kPurchaseKey"
    
    var isPurchaseEnabled: Bool {
        Bundle.main.restrictionsEnabled
    }
    
    var isMainProductPurchased: Bool {
        UserDefaults.standard.bool(forKey: purchaseKey)
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
            SwiftyStoreKit.retrieveProductsInfo([mainProductId]) { result in
                guard
                    let product = result.retrievedProducts.first,
                    result.error == nil,
                    result.invalidProductIDs.isEmpty
                else {
                    result.error?.log(message: "Failed to retrieve product \(self.mainProductId)")
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
                    UserDefaults.standard.set(true, forKey: self.purchaseKey)
                    resolver.fulfill(())
                case .error(let error):
                    error.log(message: "Puchase failed")
                    resolver.reject(PurchaseError.purchaseFailed)
                }
            }
        }
    }
}
