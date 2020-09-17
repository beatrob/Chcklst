//
//  FinalizeChecklistViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 17/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


class FinalizeChecklistViewModel: ObservableObject {
    
    @Published var isReminderOn: Bool = false
    @Published var reminderDate: Date = Date()
    
    let onCreate: EmptySubject = .init()
    let onSaveAsTemplate: EmptySubject = .init()
    
    var cancellables =  Set<AnyCancellable>()
    
    init() { }
}
