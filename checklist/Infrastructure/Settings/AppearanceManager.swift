//
//  AppearanceManager.swift
//  checklist
//
//  Created by Robert Konczi on 9/20/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import PromiseKit
import SwiftUI


enum Appearance: String, CaseIterable {
    case automatic = "Automatic"
    case light = "Light"
    case dark = "Dark"
    
    #if canImport(UIKit)
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .automatic: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }
    #endif
    
    fileprivate static var initial: Appearance {
        .automatic
    }
}

class AppearanceManager {
    
    func initializeAppAppearance() -> Promise<Void> {
        Promise {
            let currentAppearance = getCurrentAppearance()
            apply(appearance: currentAppearance)
            $0.fulfill(())
        }
    }
    
    func getCurrentAppearance() -> Appearance {
        UserDefaults.standard.appearance ?? .initial
    }
    
    func setAppearance(_ appearance: Appearance) {
        apply(appearance: appearance)
        UserDefaults.standard.setAppearance(appearance)
    }
    
    private func apply(appearance: Appearance) {
        #if canImport(UIKit)
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = appearance.userInterfaceStyle
        #endif
    }
}
