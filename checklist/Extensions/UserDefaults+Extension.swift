//
//  UserDefaults+Extension.swift
//  checklist
//
//  Created by Róbert Konczi on 10/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation


extension UserDefaults {
    
    enum Key: String {
        case appearance = "kAppearance"
        case lastViewedWelcomeWizardVersion = "kLastViewedWelcomeWizardVersion"
        
        var key: String { rawValue }
    }
    
    var appearance: Appearance? {
        guard let value = string(forKey: Key.appearance.key) else {
            return nil
        }
        return Appearance(rawValue: value)
    }
    
    func setAppearance(_ appearance: Appearance) {
        set(appearance.rawValue, forKey: Key.appearance.key)
    }

    var lastViewedWelcomeWizardVersion: Int {
        integer(forKey: Key.lastViewedWelcomeWizardVersion.key)
    }

    func setLastViewedWelcomeWizardVersion(_ version: Int) {
        set(version, forKey: Key.lastViewedWelcomeWizardVersion.key)
    }
}
