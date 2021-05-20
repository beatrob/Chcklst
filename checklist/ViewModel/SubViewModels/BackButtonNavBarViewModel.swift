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
    @Published var rightButton: NavBarChipButtonViewModel?
    let backButton = NavBarChipButtonViewModel.getBackButton()
    
    init(title: String, rightButton: NavBarChipButtonViewModel? = nil) {
        self.title = title
        self.rightButton = rightButton
    }
    
    func setRightButton(_ rightButton: NavBarChipButtonViewModel) {
        self.rightButton = rightButton
    }
}
