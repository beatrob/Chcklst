//
//  MyTemplatesViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 30/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine
import SwiftUI


class MyTemplatesViewModel: ObservableObject {
    
    @Published var title: String = ""
    
    var cancellables =  Set<AnyCancellable>()
    
    init(templateDataSource: TemplateDataSource) {
        
    }
}
