//
//  DisabledPurchaseManager.swift
//  checklist
//
//  Created by Robert Konczi on 7/1/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine

class DisabledPurchaseManager: PurchaseManager {
    
    var mainProductPurchaseState: AnyPublisher<PurchaseSate, Never> {
        CurrentValueSubject<PurchaseSate, Never>(.notPurchased).eraseToAnyPublisher()
    }
    
    func purchaseProduct(_ productDataModel: ProductDataModel) async -> Result<Bool, PurchaseError> {
        .failure(.unknown)
    }
    
    func loadPurchases() { }
    
    var isPurchaseEnabled: Bool {
        false
    }
    
    func getMainProduct() async -> Result<ProductDataModel, PurchaseError> {
        .failure(.unknown)
    }
}
