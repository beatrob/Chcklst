//
//  FilterItemData.swift
//  checklist
//
//  Created by Róbert Konczi on 09/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation

enum SortDataModel: CaseIterable, Identifiable {
    
    var id: String {
        title
    }
    
    case latest
    case oldest
    case name
    
    var title: String {
        switch self {
        case .latest: return "Latest"
        case .oldest: return "Oldest"
        case .name: return "Name"
        }
    }
    
    static let initial: SortDataModel = .latest
}
