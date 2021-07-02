//
//  ProductDataModel.swift
//  checklist
//
//  Created by Robert Konczi on 7/1/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import StoreKit

struct ProductDataModel: Identifiable {
    
    let id: String
    let localizedPrice: String
    
    init?(product: SKProduct) {
        guard let price = product.localizedPrice else {
            return nil
        }
        self.id = product.productIdentifier
        self.localizedPrice = price
    }
    
    init(id: String, localizedPrice: String) {
        self.id = id
        self.localizedPrice = localizedPrice
    }
}
