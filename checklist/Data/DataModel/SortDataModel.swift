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
    case nameAsc
    case nameDesc
    
    var title: String {
        switch self {
        case .latest: return "Latest"
        case .oldest: return "Oldest"
        case .nameAsc: return "A...Z"
        case .nameDesc: return "Z...A"
        }
    }
    
    static let initial: SortDataModel = .latest
}
