//
//  FilterItemData.swift
//  checklist
//
//  Created by Róbert Konczi on 09/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation

enum FilterItemData: CaseIterable, Identifiable {
    
    var id: String {
        title
    }
    
    case latest
    case abc
    case reminder
    case done
    case archive
    
    var imageName: String {
        switch self {
        case .latest: return "calendar.badge.clock"
        case .abc: return "textformat.abc"
        case .reminder: return "bell.badge"
        case .done: return "checkmark"
        case .archive: return "archivebox"
        }
    }
    
    var title: String {
        switch self {
        case .latest: return "Latest"
        case .abc: return "By name"
        case .reminder: return "With reminder"
        case .done: return "Done"
        case .archive: return "Archived"
        }
    }
    
    static let initial: FilterItemData = .latest
}
