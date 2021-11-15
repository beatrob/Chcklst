//
//  DayDataModel.swift
//  checklist
//
//  Created by Robert Konczi on 5/4/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation

enum DayDataModel: Int, CaseIterable {
    
    case sunday = 0
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    
    static var indexOffset = 100
    
    var title: String {
        switch self {
        case .monday:
            return "Mon"
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
    
    var index: Int {
        rawValue + Self.indexOffset
    }
    
    static var firstWeekdayNumber: Int {
        Calendar.current.firstWeekday - 1
    }
    
    static var firstWeekday: DayDataModel? {
        .init(rawValue: Self.firstWeekdayNumber)
    }
    
    var calendarWeekdayOffset: Int {
        self.rawValue + (Self.firstWeekday?.rawValue ?? 0)
    }
    
    init?(index: Int) {
        self.init(rawValue: index - Self.indexOffset)
    }
    
    static var allCases: [DayDataModel] {
        firstWeekdayNumber == 1 ?
            [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday] :
            [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    }
}
