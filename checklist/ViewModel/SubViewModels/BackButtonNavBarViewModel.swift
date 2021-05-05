//
//  TemplatesNavBarViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 22.03.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


class BackButtonNavBarViewModel: ObservableObject {
    
    @Published var title: String
    let backButton = NavBarChipButtonViewModel.getBackButton()
    
    init(title: String) {
        self.title = title
    }
}
