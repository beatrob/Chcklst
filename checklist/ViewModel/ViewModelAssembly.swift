//
//  ViewModelAssembly.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Swinject
import SwinjectAutoregistration

class ViewModelAssembly: Assembly {
    
    func assemble(container: Container) {
        container.autoregister(DashboardViewModel.self, initializer: DashboardViewModel.init)
    }
}
