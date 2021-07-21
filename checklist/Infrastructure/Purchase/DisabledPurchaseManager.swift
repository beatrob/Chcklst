//
//  DisabledPurchaseManager.swift
//  checklist
//
//  Created by Robert Konczi on 7/1/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import PromiseKit
import Combine

class DisabledPurchaseManager: PurchaseManager {
    
    var mainProductPurchasedPublisher: AnyPublisher<Bool, Never> {
        CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
    }
    
    var isPurchaseEnabled: Bool {
        false
    }
    
    func completeTransactions() { }
    
    func getMainProduct() -> Promise<ProductDataModel> {
        .init(error: NSError())
    }
    
    func purchaseProduct(_ product: ProductDataModel) -> Promise<Void> {
        .init(error: NSError())
    }
    
    func restorePurchase() -> Promise<Void> {
        .init(error: NSError())
    }
}
