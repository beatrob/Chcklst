//
//  RestrictionManager.swift
//  checklist
//
//  Created by Robert Konczi on 6/27/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation

protocol RestrictionManager {
    var restrictionsEnabled: Bool { get }
}

class RestrictionManagerImpl: RestrictionManager {
    
    let restrictionsEnabled: Bool = Bundle.main.restrictionsEnabled
}
