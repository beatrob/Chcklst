//
//  AnyView+Extension.swift
//  checklist
//
//  Created by Róbert Konczi on 08/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI


extension AnyView {
    
    static var empty: AnyView {
        AnyView(EmptyView())
    }
}
