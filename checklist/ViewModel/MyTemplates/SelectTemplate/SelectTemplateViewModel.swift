//
//  SelectTemplateViewModel.swift
//  checklist
//
//  Created by Róbert Konczi on 01/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import Combine


class SelectTemplateViewModel: ObservableObject {
    
    @Published var templates: [TemplateDataModel] = [] {
        didSet {
            isEmptyListViewVisible = templates.isEmpty
        }
    }
    
    @Published var isEmptyListViewVisible = false
    var cancellables =  Set<AnyCancellable>()
    
    init(templateDataSource: TemplateDataSource) {
        templateDataSource.templates.sink { [weak self] templates in
            self?.templates = templates
        }.store(in: &cancellables)
    }
}
