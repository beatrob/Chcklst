//
//  TextReaderViewModel.swift
//  checklist
//
//  Created by Robert Konczi on 9/27/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Combine
import SwiftUI


class TextReaderViewModel: ObservableObject {
    
    @Published var text: LocalizedStringKey
    let navbarViewModel: BackButtonNavBarViewModel
    let onBackTapped: EmptyPublisher
    var title: LocalizedStringKey {
        get { navbarViewModel.title }
        set { navbarViewModel.title = newValue }
    }
    
    init(title: LocalizedStringKey, text: LocalizedStringKey, isBackButtonHidden: Bool) {
        navbarViewModel = .init(title: title)
        navbarViewModel.style = .big
        navbarViewModel.isBackButtonHidden = isBackButtonHidden
        self.text = text
        onBackTapped = navbarViewModel.backButton.didTap
    }
}
