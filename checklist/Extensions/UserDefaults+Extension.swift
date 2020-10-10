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
        
        var key: String { rawValue }
    }
    
    var isAppInitialized: Bool {
        bool(forKey: Key.isAppInitialized.key)
    }
    
    func setAppInitialized() {
        set(true, forKey: Key.isAppInitialized.key)
    }
}
