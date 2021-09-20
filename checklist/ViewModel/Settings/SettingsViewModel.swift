//
//  SettingsViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 23/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


class SettingsViewModel: ObservableObject {
    
    let navBarViewModel = AppContext.resolver.resolve(BackButtonNavBarViewModel.self, argument: "Settings")!
    let onMyTemplates = EmptySubject()
    let onUpgradeTapped = EmptySubject()
    let isInAppEnabled: Bool
    var cancellables =  Set<AnyCancellable>()
    var sheet: AnyView = .empty
    lazy var upgradeViewModel: UpgradeViewModel = {
        let viewModel = AppContext.resolver.resolve(UpgradeViewModel.self)!
        viewModel.onCancelTapped.sink { [weak self] in
            self?.isSheetVisible = false
        }.store(in: &self.cancellables)
        return viewModel
    }()
    @Published var isSheetVisible = false
    @Published var isUpgradeComplete = false
    @Published var apperance: Appearance
    
    var onBackTapped: EmptyPublisher {
        navBarViewModel.backButton.didTap.eraseToAnyPublisher()
    }
    
    init(
        navigationHelper: NavigationHelper,
        restrictionManager: RestrictionManager,
        purchaseManager: PurchaseManager,
        appearanceManager: AppearanceManager
    ) {
        apperance = appearanceManager.getCurrentAppearance()
        isInAppEnabled = restrictionManager.restrictionsEnabled
        onMyTemplates.sink {
            navigationHelper.navigateToMyTemplates(source: .settings)
        }.store(in: &cancellables)
        
        onUpgradeTapped.sink { [weak self] in
            guard let self = self else {
                return
            }
            self.sheet = AnyView(UpgradeView(viewModel: self.upgradeViewModel))
            self.isSheetVisible = true
        }.store(in: &cancellables)
        
        purchaseManager.mainProductPurchasedPublisher
            .assign(to: \.isUpgradeComplete, on: self)
            .store(in: &cancellables)
        
        $apperance.dropFirst().sink { apperance in
            appearanceManager.setAppearance(apperance)
        }.store(in: &cancellables)
    }
}
