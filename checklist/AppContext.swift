//
//  AppModul.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Swinject
import Combine
import UIKit

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
    
    init() { }
    
    func configure() { }
    
    var statusBarHeight: CGFloat {
        #if canImport(UIKit)
        let scene = UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
        return scene?.statusBarManager?.statusBarFrame.height ?? 0
        #else
        return 0
        #endif
    }
}
