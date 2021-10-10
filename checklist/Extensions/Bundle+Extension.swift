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
        guard let rawValue = self.infoDictionary?["restrictionsEnabledString"] as? String else {
            return false
        }
        return rawValue.caseInsensitiveCompare("yes") == .orderedSame
    }
    
    var numberOfFreeChecklists: Int? {
        getInt(for: "numberOfFreeChecklists")
    }
    
    var numberOfFreeTemplates: Int? {
        getInt(for: "numberOfFreeTemplates")
    }
    
    var numberOfFreeSchedules: Int? {
        getInt(for: "numberOfFreeSchedules")
    }
}


private extension Bundle {
    
    func getInt(for key: String) -> Int? {
        self.infoDictionary?[key] as? Int
    }
}
