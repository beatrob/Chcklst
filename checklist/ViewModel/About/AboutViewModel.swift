//
//  AboutViewModel.swift
//  checklist
//
//  Created by Robert Konczi on 9/23/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI
import Combine


class AboutViewModel: ObservableObject {
    
    let navbarViewModel = BackButtonNavBarViewModel(title: "About")
    private var cancellables = Set<AnyCancellable>()
    let onHelp = EmptySubject()
    let onTermsAndConditions = EmptySubject()
    let onPrivacyPolicy = EmptySubject()
    @Published var isSheetVisible = false
    @Published var sheet = AnyView.empty
    
    init(notificationManager: NotificationManager) {
        onTermsAndConditions.sink { [weak self] in
            let viewModel = TextReaderViewModel(
                title: .init("terms_and_conditions_title"),
                text: .init("terms_and_conditions_text"),
                isBackButtonHidden: true
            )
            self?.sheet = AnyView(TextReaderView(viewModel: viewModel))
            self?.isSheetVisible = true
        }.store(in: &cancellables)
        
        onPrivacyPolicy.sink { [weak self] in
            let viewModel = TextReaderViewModel(
                title: .init("privacy_policy_title"),
                text: .init("privacy_policy_text"),
                isBackButtonHidden: true
            )
            self?.sheet = AnyView(TextReaderView(viewModel: viewModel))
            self?.isSheetVisible = true
        }.store(in: &cancellables)
        
        onHelp.sink { [weak self] in
            let viewModel = HelpViewModel()
            self?.sheet = AnyView(HelpView(viewModel: viewModel))
            self?.isSheetVisible = true
        }.store(in: &cancellables)
        
        notificationManager.deeplinkChecklistId
            .merge(with: notificationManager.deeplinkScheduleId)
            .sink { [weak self] _ in
                self?.isSheetVisible = false
                self?.sheet = .empty
            }.store(in: &cancellables)
    }
}
