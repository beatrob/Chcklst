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
    let items = Item.allCases
    let didSelectItem = PassthroughSubject<Item, Never>()
    @Published var navigationLinkDestination: AnyView = .empty
    @Published var isNavigationLinkActive = false
    
    init() {
        didSelectItem.sink { [weak self] item in
            let viewModel = TextReaderViewModel(title: item.title, text: item.text)
            self?.navigationLinkDestination = AnyView(TextReaderView(viewModel: viewModel))
            self?.isNavigationLinkActive = true
        }.store(in: &cancellables)
    }
}
