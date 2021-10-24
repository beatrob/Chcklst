//
//  FilterItemData.swift
//  checklist
//
//  Created by Róbert Konczi on 09/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation

enum FilterDataModel: CaseIterable, Identifiable {
    
    var id: String {
        title
    }
    
    case withReminder
    case done
    case none
    
    var title: String {
        switch self {
        case .withReminder: return "Reminder set"
        case .done: return "Done"
        case .none: return "None"
        }
    }
    
    var isVisibleInNavbar: Bool {
        switch self {
        case .none:
            return false
        default:
            return true
        }
    }
    
    static var initial: FilterDataModel = .none
}
