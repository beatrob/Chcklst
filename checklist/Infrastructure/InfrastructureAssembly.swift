//
//  InfrastructureAssembly.swift
//  checklist
//
//  Created by Róbert Konczi on 07/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Swinject
import SwinjectAutoregistration


class InfrastructureAssembly: Assembly {
    
    func assemble(container: Container) {
        container.autoregister(NavigationHelper.self, initializer: NavigationHelper.init).inObjectScope(.container)
        container.autoregister(NotificationManager.self, initializer: NotificationManager.init).inObjectScope(.container)
        container.autoregister(ChecklistFilterAndSort.self, initializer: ChecklistFilterAndSortImpl.init)
    }
}
