//
//  MockPurchaseManager.swift
//  checklist
//
//  Created by Robert Konczi on 7/1/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine

class MockPurchaseManager: PurchaseManager {
    
    var mainProductPurchaseState: AnyPublisher<PurchaseSate, Never> {
        CurrentValueSubject<PurchaseSate, Never>(.notPurchased).eraseToAnyPublisher()
    }
    
    func purchaseProduct(_ productDataModel: ProductDataModel) async -> Result<Bool, PurchaseError> {
        .success(false)
    }
    
    func restorePurchase(
        _ productDataModel: ProductDataModel?,
        shouldSync: Bool
    ) async -> Result<Bool, PurchaseError> {
        .success(false)
    }
    
    var isPurchaseEnabled: Bool {
        true
    }
    
    func getMainProduct() async -> Result<ProductDataModel, PurchaseError> {
        .success(.init(id: "1234", title: "Chcklist Plus", localizedPrice: "3.99$"))
    }
}
