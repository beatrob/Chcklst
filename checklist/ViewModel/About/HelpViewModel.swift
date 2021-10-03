//
//  HelpViewModel.swift
//  checklist
//
//  Created by Robert Konczi on 9/30/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Combine
import SwiftUI


class HelpViewModel: ObservableObject {
    
    enum Item: String, CaseIterable, Identifiable {
        case checklists
        case templates
        case schedules
        case chcklstplus
        
        private static var prefix = "help_"
        
        var id: String { self.rawValue }
        
        var title: LocalizedStringKey {
            .init(Self.prefix + self.rawValue + "_title")
        }
        
        var text: LocalizedStringKey {
            .init(Self.prefix + self.rawValue + "_text")
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let textReaderViewModel = TextReaderViewModel(
        title: .init(""),
        text: .init(""),
        isBackButtonHidden: false
    )
    let items = Item.allCases
    let didSelectItem = PassthroughSubject<Item, Never>()
    let navigationBarViewModel = BackButtonNavBarViewModel(title: LocalizedStringKey("help_title"))
    @Published var navigationLinkDestination: AnyView = .empty
    @Published var isNavigationLinkActive = false
    
    init() {
        navigationBarViewModel.style = .big
        navigationBarViewModel.isBackButtonHidden = true
        didSelectItem.sink { [weak self] item in
            guard let self = self else {
                return
            }
            self.textReaderViewModel.title = item.title
            self.textReaderViewModel.text = item.text
            self.navigationLinkDestination = AnyView(TextReaderView(viewModel: self.textReaderViewModel))
            self.isNavigationLinkActive = true
        }.store(in: &cancellables)
        
        textReaderViewModel.onBackTapped.sink { [weak self] in
            self?.isNavigationLinkActive = false
            self?.navigationLinkDestination = .empty
        }.store(in: &cancellables)
    }
}
