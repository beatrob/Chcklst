//
//  RestrictionManager.swift
//  checklist
//
//  Created by Robert Konczi on 6/27/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import PromiseKit
import Combine
import SwiftUI

protocol RestrictionManager {
    var restrictionsEnabled: Bool { get }
    func verifyCreateChecklist(presenter: RestrictionPresenter) -> Promise<Bool>
    func verifyCreateTemplate(presenter: RestrictionPresenter) -> Promise<Bool>
    func verifyCreateSchedule(presenter: RestrictionPresenter) -> Promise<Bool>
}


class RestrictionManagerImpl: RestrictionManager {
    
    let restrictionsEnabled: Bool = Bundle.main.restrictionsEnabled
    
    private var cancellables = Set<AnyCancellable>()
    private let checklistCount: CurrentValueSubject<Int, Never> = .init(0)
    private let templateCount: CurrentValueSubject<Int, Never> = .init(0)
    private let scheduleCount: CurrentValueSubject<Int, Never> = .init(0)
    private let isMainProductPurchased: CurrentValueSubject<Bool, Never> = .init(false)
    private var upgradeSignalsRegistered = false
    private lazy var upgradeViewModel = AppContext.resolver.resolve(UpgradeViewModel.self)!
    private var currentResolver: Resolver<Bool>?
    private weak var currentPresenter: RestrictionPresenter?
    
    init(
        checklistDataSource: ChecklistDataSource,
        templateDataSource: TemplateDataSource,
        scheduleDataSource: ScheduleDataSource,
        purchaseManager: PurchaseManager
    ) {
        checklistDataSource.checkLists
            .map { $0.count }
            .subscribe(checklistCount)
            .store(in: &cancellables)
        templateDataSource.templates
            .map { $0.count }
            .subscribe(templateCount)
            .store(in: &cancellables)
        scheduleDataSource.schedules
            .map { $0.count }
            .subscribe(scheduleCount)
            .store(in: &cancellables)
        purchaseManager.mainProductPurchaseState
            .map { $0.isPurchased }
            .subscribe(isMainProductPurchased)
            .store(in: &cancellables)
    }
    
    func verifyCreateChecklist(presenter: RestrictionPresenter) -> Promise<Bool> {
        guard
            !isMainProductPurchased.value,
            let maxFreeChecklists = Bundle.main.numberOfFreeChecklists,
            self.checklistCount.value > maxFreeChecklists
        else {
            return .value(true)
        }
        return firstly {
            self.registerPresenter(presenter: presenter)
        }.then {
            self.displayLimitReachedAlert(title: .init("upgrade_alert_checklist_limit_reached"))
        }.then { tapAction -> Promise<Bool> in
            guard tapAction != .cancel else {
                return .value(false)
            }
            return self.displayUpgradeView()
        }.ensure {
            self.currentPresenter = nil
        }
    }
    
    func verifyCreateTemplate(presenter: RestrictionPresenter) -> Promise<Bool> {
        guard
            !isMainProductPurchased.value,
            let maxFreeTemplates = Bundle.main.numberOfFreeTemplates,
            self.checklistCount.value > maxFreeTemplates
        else {
            return .value(true)
        }
        return firstly {
            self.registerPresenter(presenter: presenter)
        }.then {
            self.displayLimitReachedAlert(
                title: .init("upgrade_alert_template_limit_reached"),
                customMessage: .init("upgrade_alert_template_limit_reached_message")
            )
        }.then { tapAction -> Promise<Bool> in
            guard tapAction != .cancel else {
                return .value(false)
            }
            return self.displayUpgradeView()
        }.ensure {
            self.currentPresenter = nil
        }
    }
    
    func verifyCreateSchedule(presenter: RestrictionPresenter) -> Promise<Bool> {
        .value(true)
    }
}

private extension RestrictionManagerImpl {
    
    func registerPresenter(presenter: RestrictionPresenter) -> Guarantee<Void> {
        self.currentPresenter = presenter
        return .value
    }
    
    func displayLimitReachedAlert(
        title: LocalizedStringKey,
        customMessage: LocalizedStringKey? = nil
    ) -> Guarantee<LimitReachedAlert.TapAction> {
        Guarantee { resolver in
            let alert = LimitReachedAlert.getAlert(
                title: title,
                customMessage: customMessage
            ) { tapAction in
                resolver(tapAction)
            }
            self.currentPresenter?.presentRestrictionAlert(alert)
        }
    }
    
    func displayUpgradeView() -> Promise<Bool> {
        registerUpgradeViewModelSignals()
        return Promise { resolver in
            let view = UpgradeView(viewModel: self.upgradeViewModel)
            self.currentPresenter?.presentUpgradeView(view)
            self.currentResolver = resolver
        }.ensure {
            self.currentResolver = nil
        }
    }
    
    func registerUpgradeViewModelSignals() {
        guard !upgradeSignalsRegistered else {
            return
        }
        upgradeViewModel.onCancelTapped.sink { [weak self] in
            self?.currentPresenter?.cancelUpgradeView()
            self?.currentResolver?.fulfill(false)
        }.store(in: &cancellables)
        
        upgradeViewModel.onPurchaseSuccess.sink { [weak self] in
            self?.currentPresenter?.dismissUpgradeView()
            self?.currentResolver?.fulfill(true)
        }.store(in: &cancellables)
        
        upgradeSignalsRegistered = true
    }
}
