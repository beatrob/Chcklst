//
//  Alert+Extension.swift
//  checklist
//
//  Created by Róbert Konczi on 11.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI


extension Alert {
    
    static var empty: Alert {
        Alert(title: Text(""))
    }
}
