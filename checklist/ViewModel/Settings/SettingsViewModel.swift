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
    @Published var isSheetVisible = false
    
    var onBackTapped: EmptyPublisher {
        navBarViewModel.backButton.didTap.eraseToAnyPublisher()
    }
    
    init(navigationHelper: NavigationHelper, restrictionManager: RestrictionManager) {
        isInAppEnabled =  restrictionManager.restrictionsEnabled
        onMyTemplates.sink {
            navigationHelper.navigateToMyTemplates(source: .settings)
        }.store(in: &cancellables)
        
        onUpgradeTapped.sink { [weak self] in
            self?.sheet = AnyView(UpgradeView(viewModel: AppContext.resolver.resolve(UpgradeViewModel.self)!))
            self?.isSheetVisible = true
        }.store(in: &cancellables)
    }
}
