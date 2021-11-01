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
    
    private let notificationManager: NotificationManager
    static var latestNotificationsEnabled: Bool = false
    let navBarViewModel = AppContext.resolver.resolve(BackButtonNavBarViewModel.self, argument: "Settings")!
    let onMyTemplates = EmptySubject()
    let onUpgradeTapped = EmptySubject()
    let onViewAppear = EmptySubject()
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
    @Published var notificationsEnabled: Bool = SettingsViewModel.latestNotificationsEnabled
    @Published var apperance: Appearance
    @Published var alert: Alert = .empty
    @Published var isAlertVisible = false
    
    var onBackTapped: EmptyPublisher {
        navBarViewModel.backButton.didTap.eraseToAnyPublisher()
    }
    
    init(
        navigationHelper: NavigationHelper,
        restrictionManager: RestrictionManager,
        purchaseManager: PurchaseManager,
        appearanceManager: AppearanceManager,
        notificationManager: NotificationManager
    ) {
        self.notificationManager = notificationManager
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
        
        purchaseManager.mainProductPurchaseState
            .map { $0.isPurchased }
            .assign(to: \.isUpgradeComplete, on: self)
            .store(in: &cancellables)
        
        $apperance.dropFirst().sink { apperance in
            appearanceManager.setAppearance(apperance)
        }.store(in: &cancellables)
        
        $notificationsEnabled.dropFirst().sink { isEnabled in
            guard Self.latestNotificationsEnabled != isEnabled else {
                return
            }
            if isEnabled {
                notificationManager.registerPushNotifications().done { granted in
                    if granted {
                        Self.latestNotificationsEnabled = true
                    } else {
                        self.showOpenSetingsAlert(shouldEnableNotifications: true)
                    }
                }.catch { error in
                    error.log(message: "Failed to register push notifications")
                }
            } else {
                self.showOpenSetingsAlert(shouldEnableNotifications: false)
            }
        }.store(in: &cancellables)
        
        onViewAppear.sink { [weak self] in
            self?.reloadNotificationsState()
        }.store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.reloadNotificationsState()
            }.store(in: &cancellables)
        
        notificationManager.deeplinkScheduleId
            .merge(with: notificationManager.deeplinkChecklistId)
            .sink { [weak self] _ in
                self?.isSheetVisible = false
                self?.sheet = .empty
            }.store(in: &cancellables)
    }
    
    private func showOpenSetingsAlert(shouldEnableNotifications: Bool) {
        self.alert = Alert.getEnablePushNotifications(
            shouldEnableNotifications: shouldEnableNotifications
        ) { [weak self] in
            self?.reloadNotificationsState()
        }
        self.isAlertVisible = true
    }
    
    private func reloadNotificationsState() {
        notificationManager.getNotificationsEnabled().done { isEnabled in
            Self.latestNotificationsEnabled = isEnabled
            self.notificationsEnabled = isEnabled
        }
    }
}
