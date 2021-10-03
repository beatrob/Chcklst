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
    
    enum Style {
        case normal
        case big
        
        var isBig: Bool {
            self == .big
        }
    }
    
    @Published var title: LocalizedStringKey
    @Published var rightButton: NavBarChipButtonViewModel?
    @Published var isBackButtonHidden = false
    @Published var style: Style = .normal
    let backButton = NavBarChipButtonViewModel.getBackButton()
    
    init(title: String, rightButton: NavBarChipButtonViewModel? = nil) {
        self.title = .init(title)
        self.rightButton = rightButton
    }
    
    init(title: LocalizedStringKey) {
        self.title = title
    }
    
    func setRightButton(_ rightButton: NavBarChipButtonViewModel) {
        self.rightButton = rightButton
    }
}
