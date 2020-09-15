//
//  ViewVisibility.swift
//  checklist
//
//  Created by Róbert Konczi on 15/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI

class ViewVisibility<SomeView> {
    @Published var isVisible = false
    var view: SomeView
    
    init(view: SomeView) {
        self.view = view
    }
    
    func set(view: SomeView, isVisible: Bool) {
        self.view = view
        self.isVisible = isVisible
    }
}
