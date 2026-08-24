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
    @Published var searchText = ""
    @Published var isEmptyListViewVisible = false
    var cancellables =  Set<AnyCancellable>()

    var filteredTemplates: [TemplateDataModel] {
        templates.filter { $0.matchesSearchText(searchText) }
    }

    var isNoSearchResultsVisible: Bool {
        !templates.isEmpty && filteredTemplates.isEmpty
    }

    var isSearchVisible: Bool { !templates.isEmpty }
    
    init(templateDataSource: TemplateDataSource) {
        templateDataSource.templates.sink { [weak self] templates in
            self?.templates = templates
        }.store(in: &cancellables)
    }
}
