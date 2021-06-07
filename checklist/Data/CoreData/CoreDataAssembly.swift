//
//  CoreDataAssembly.swift
//  checklist
//
//  Created by Róbert Konczi on 27/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Swinject
import SwinjectAutoregistration


class CoreDataAssembly: Assembly {
    
    func assemble(container: Container) {
        container.autoregister(CoreDataManager.self, initializer: CoreDataManagerImpl.init)
            .implements(CoreDataChecklistManager.self, CoreDataTemplateManager.self, CoreDataSchedulesManager.self)
            .inObjectScope(.container)
    }
}
