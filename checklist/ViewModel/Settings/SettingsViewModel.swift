//
//  SettingsViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 23/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


class SettingsViewModel: ObservableObject {
    
    @Published var isViewToNavigateVisible = false
    
    let onMyTemplates = EmptySubject()
    var cancellables =  Set<AnyCancellable>()
    var navigation: SettingsNavigation = .none {
        didSet {
            self.isViewToNavigateVisible = navigation.isViewVisible
        }
    }
    var viewToNavigate: AnyView { navigation.view }
    
    init() {
        onMyTemplates.sink { [weak self] in
            self?.navigation = .myTemplates
        }.store(in: &cancellables)
    }
}
