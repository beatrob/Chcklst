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
        case isAppInitialized = "kIsAppInitialized"
        case appearance = "kAppearance"
        
        var key: String { rawValue }
    }
    
    var isAppInitialized: Bool {
        bool(forKey: Key.isAppInitialized.key)
    }
    
    func setAppInitialized() {
        set(true, forKey: Key.isAppInitialized.key)
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
}
