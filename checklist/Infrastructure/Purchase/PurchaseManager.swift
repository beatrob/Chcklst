//
//  PurchaseManager.swift
//  checklist
//
//  Created by Robert Konczi on 7/1/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import StoreKit

enum PurchaseSate {
    case purchased
    case notPurchased
    case pending
    case unknown
    case inProgress
    
    var isPurchased: Bool {
        self == .purchased
    }
}

enum PurchaseError: LocalizedError {
    
    case retrieveFailed
    case productError
    case purchaseFailed
    case restoreFailed
    case nothingToRestore
    case verifyTransactionFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .retrieveFailed:
            return "Laoding failed, try again later"
        case .productError:
            return "Something went wrong, try again later"
        case .purchaseFailed:
            return "Purchase failed, try again later"
        case .restoreFailed:
            return "Restore purchase failed"
        case .nothingToRestore:
            return "No previous purchase found"
        case .verifyTransactionFailed:
            return "Verify transaction failed"
        case .unknown:
            return "Something went wrong, try again later"
        }
    }
}

protocol PurchaseManager {
    var isPurchaseEnabled: Bool { get }
    var mainProductPurchaseState: AnyPublisher<PurchaseSate, Never> { get }
    func getMainProduct() async -> Result<ProductDataModel, PurchaseError>
    func purchaseProduct(_ productDataModel: ProductDataModel) async -> Result<Bool, PurchaseError>
    func restorePurchase(_ productDataModel: ProductDataModel?, shouldSync: Bool) async -> Result<Bool, PurchaseError>
}

class PurchaseManagerImpl: PurchaseManager {
    
    private static let mainProductId = "com.robertkonczi.chcklst.plus"
    private static let sharedSecret = "23e338469a214b8594d7cfbd8036bddb"
    private let mainProductPuchaseStateSubject = CurrentValueSubject<PurchaseSate, Never>(.notPurchased)
    private var cancellables = Set<AnyCancellable>()
    private var products: [Product]?
    private var purchaseListener: Task<Void, Error>?
    
    var isPurchaseEnabled: Bool {
        Bundle.main.restrictionsEnabled
    }
    
    init() {
        purchaseListener = listenForTransactions()
    }
    
    var mainProductPurchaseState: AnyPublisher<PurchaseSate, Never> {
        mainProductPuchaseStateSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func getMainProduct() async -> Result<ProductDataModel, PurchaseError> {
        do {
            let storeProducts = try await Product.products(for: [Self.mainProductId])
            guard let product = storeProducts.first else {
                throw PurchaseError.retrieveFailed
            }
            self.products = storeProducts
            return .success(
                .init(id: product.id, title: product.displayName, localizedPrice: product.displayPrice)
            )
        } catch {
            error.log(message: "Failed to retrieve main product")
            return .failure(PurchaseError.retrieveFailed)
        }
    }
    
    func purchaseProduct(_ productDataModel: ProductDataModel) async -> Result<Bool, PurchaseError> {
        do {
            guard let product = self.products?.first(where: { $0.id == productDataModel.id}) else {
                throw PurchaseError.purchaseFailed
            }
            await updatePurchaseState(with: nil, forcedState: .inProgress)
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchaseState(with: transaction)
                await transaction.finish()
                return .success(true)
            case .pending:
                await updatePurchaseState(with: nil, forcedState: .pending)
                return .success(false)
            case .userCancelled:
                await updatePurchaseState(with: nil, forcedState: .notPurchased)
                return .success(false)
            @unknown default:
                await updatePurchaseState(with: nil, forcedState: .unknown)
                return .success(false)
            }
        } catch {
            error.log(message: "Purchase failed")
            return .failure(PurchaseError.purchaseFailed)
        }
    }
    
    func restorePurchase(
        _ productDataModel: ProductDataModel?,
        shouldSync: Bool
    ) async -> Result<Bool, PurchaseError> {
        let productId = productDataModel?.id ?? Self.mainProductId
        do {
            await updatePurchaseState(with: nil, forcedState: .inProgress)
            if shouldSync {
                try await AppStore.sync()
            }
            guard
                let result = await Transaction.latest(for: productId)
            else {
                await updatePurchaseState(with: nil, forcedState: .notPurchased)
                return .failure(.nothingToRestore)
            }
            let transaction = try self.checkVerified(result)
            await updatePurchaseState(with: transaction)
            await transaction.finish()
        } catch {
            await updatePurchaseState(with: nil, forcedState: .notPurchased)
            error.log(message: "Restore purchase failed")
            return .failure(.restoreFailed)
        }
        return .success(true)
    }
}


private extension PurchaseManagerImpl {
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw PurchaseError.verifyTransactionFailed
        }
    }
    
    @MainActor
    func updatePurchaseState(with transaction: Transaction?, forcedState: PurchaseSate? = nil) {
        if let forcedState = forcedState {
            mainProductPuchaseStateSubject.send(forcedState)
            return
        }
        guard
            let transaction = transaction,
            transaction.productID == Self.mainProductId
        else {
            return
        }
        if transaction.revocationDate == nil {
            mainProductPuchaseStateSubject.send(.purchased)
        } else {
            mainProductPuchaseStateSubject.send(.notPurchased)
        }
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        .detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchaseState(with: transaction)
                    await transaction.finish()
                } catch {
                    error.log(message: "Listen for transaction failed")
                }
            }
        }
    }
}
