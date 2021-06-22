//
//  AppModul.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Swinject
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import Combine

class AppContext {
    
    static let didEnterForeground = PassthroughSubject<Void, Never>()
    static let shared = AppContext()
    static var resolver: Resolver {
        shared.resolver
    }
    
    private let assembler = Assembler(
        [
            DataSourceAssembly(),
            ViewModelAssembly(),
            InfrastructureAssembly(),
            CoreDataAssembly()
        ]
    )
    
    var resolver: Resolver {
        assembler.resolver
    }
    
    init() {
        AppCenter.start(
            withAppSecret: "2e52e116-6ccb-40e4-a8d9-e91aa19173b4",
            services: [Analytics.self, Crashes.self]
        )
    }
    
    func configure() { }
}
