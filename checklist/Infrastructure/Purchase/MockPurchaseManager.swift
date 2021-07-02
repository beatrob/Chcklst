//
//  MockPurchaseManager.swift
//  checklist
//
//  Created by Robert Konczi on 7/1/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import PromiseKit

class MockPurchaseManager: PurchaseManager {
    
    var isMainProductPurchased: Bool {
        false
    }
    
    var isPurchaseEnabled: Bool {
        true
    }
    
    func completeTransactions() { }
    
    func getMainProduct() -> Promise<ProductDataModel> {
        .value(.init(id: "1234", localizedPrice: "3.99$"))
    }
    
    func purchaseProduct(_ product: ProductDataModel) -> Promise<Void> {
        .value
    }
}
