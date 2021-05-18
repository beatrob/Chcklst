//
//  DayDataModel.swift
//  checklist
//
//  Created by Robert Konczi on 5/4/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation

enum DayDataModel: Int, CaseIterable {
    case monday = 100
    case tuesday = 101
    case wednesday = 102
    case thursday = 103
    case friday = 104
    case saturday = 105
    case sunday = 106
    
    var title: String {
        switch self {
        case .monday:
            return "Mo"
        case .tuesday:
            return "Tue"
        case .wednesday:
            return "Wed"
        case .thursday:
            return "Thu"
        case .friday:
            return "Fri"
        case .saturday:
            return "Sat"
        case .sunday:
            return "Sun"
        }
    }
}
