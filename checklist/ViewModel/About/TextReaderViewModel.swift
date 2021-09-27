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
    
    @Published var title: LocalizedStringKey
    @Published var text: LocalizedStringKey
    
    init(title: LocalizedStringKey, text: LocalizedStringKey) {
        self.title = title
        self.text = text
    }
}
