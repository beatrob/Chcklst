//
//  AppModul.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Swinject

class AppContext {
    
    static let shared = AppContext()
    static var resolver: Resolver {
        shared.resolver
    }
    
    private let assembler = Assembler(
        [
            MockDataSourceAssembly(),
            ViewModelAssembly()
        ]
    )
    
    var resolver: Resolver {
        assembler.resolver
    }
    
    func configure() { }
}
