//
//  DashboardNavBarViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 18.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


class NavBarChipButtonViewModel: ObservableObject {
    
    @Published var title: String?
    @Published var icon: Image?
    private var cancellables = Set<AnyCancellable>()
    let didTap = EmptySubject()
    
    init(title: String?, icon: Image?) {
        self.title = title
        self.icon = icon
    }
}
