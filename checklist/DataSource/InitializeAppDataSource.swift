//
//  InitializeAppDataSource.swift
//  checklist
//
//  Created by Róbert Konczi on 10/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import PromiseKit


protocol InitializeAppDataSource {
    func initializeApp() -> Promise<Void>
}


class InitializeAppDataSourceImpl: InitializeAppDataSource {
    
    let coreDataManager: CoreDataChecklistManager
    let userDefaults = UserDefaults.standard
    
    init(coreDataManager: CoreDataChecklistManager) {
        self.coreDataManager = coreDataManager
    }
    
    func initializeApp() -> Promise<Void> {
        guard !userDefaults.isAppInitialized else {
            return .value
        }
        return initializeWelcomeData()
            .get { self.userDefaults.setAppInitialized() }
    }
}


private extension InitializeAppDataSourceImpl {
    
    func initializeWelcomeData() -> Promise<Void> {
        return coreDataManager.save(checklist: ChecklistDataModel.getWelcomeChecklist())
    }
}
