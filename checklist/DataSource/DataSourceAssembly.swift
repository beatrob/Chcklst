//
//  DataSourceAssembly.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Swinject
import SwinjectAutoregistration


class DataSourceAssembly: Assembly {
    
    func assemble(container: Container) {
        container.autoregister(ChecklistDataSource.self, initializer: CheckListDataSourceImpl.init)
        container.autoregister(TemplateDataSource.self, initializer: TemplateDataSourceImpl.init)
    }
}


class MockDataSourceAssembly: Assembly {
    
    func assemble(container: Container) {
        container.autoregister(ChecklistDataSource.self, initializer: MockChecklistDataSource.init)
        container.autoregister(TemplateDataSource.self, initializer: MockTemplateDataSource.init)
    }
}

