//
//  Bundle+Extension.swift
//  checklist
//
//  Created by Robert Konczi on 6/27/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation

extension Bundle {
    
    var restrictionsEnabled: Bool {
        guard let rawValue = Bundle.main.infoDictionary?["restrictionsEnabledString"] as? String else {
            return false
        }
        return rawValue.caseInsensitiveCompare("yes") == .orderedSame
    }
}
