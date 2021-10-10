//
//  RestrictionPresenter.swift
//  checklist
//
//  Created by Robert Konczi on 10/3/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI


protocol RestrictionPresenter: AnyObject {
    
    func presentRestrictionAlert(_ alert: Alert)
    func presentUpgradeView(_ upgradeView: UpgradeView)
    func cancelUpgradeView()
    func dismissUpgradeView()
}
