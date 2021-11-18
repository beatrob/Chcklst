//
//  DayDataModel.swift
//  checklist
//
//  Created by Robert Konczi on 5/4/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation

enum DayDataModel: Int, CaseIterable {
    
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
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
    
    static var firstWeekday: DayDataModel? {
        .init(rawValue: Calendar.current.firstWeekday)
    }
    
    var calendarWeekdayOffset: Int {
        self.rawValue
    }
    
    init?(index: Int) {
        self.init(rawValue: index - Self.indexOffset)
    }
    
    static var allCases: [DayDataModel] {
        Calendar.current.firstWeekday == 1 ?
            [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday] :
            [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    }
}
