//
//  InitializeAppViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 28/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import PromiseKit


class InitializeAppViewModel: ObservableObject {
    
    var cancellables =  Set<AnyCancellable>()
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    let initializeDidFinish: EmptySubject = .init()
    
    init(
        coreDataManager: CoreDataManager,
        checklistDataSource: ChecklistDataSource,
        templateDataSource: TemplateDataSource
    ) {
        coreDataManager.initialize()
            .then { checklistDataSource.loadAllChecklists().asVoid() }
            .then { templateDataSource.loadAllTemplates().asVoid() }
            .then { after(seconds: 1) }
            .done { self.initializeDidFinish.send() }
            .ensure { self.isLoading = false }
            .catch { error in
                self.errorMessage = error.localizedDescription
            }
    }
}
