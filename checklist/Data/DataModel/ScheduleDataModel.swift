//
//  ScheduleDataModel.swift
//  checklist
//
//  Created by Robert Konczi on 5/4/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation

struct ScheduleDataModel: Equatable {
    
    enum RepeatFrequency: CaseIterable, Identifiable {
        
        case never
        case daily
        case customDays(days: [DayDataModel])
        case weekly
        case fortnightly
        case monthly
        case yearly
        
        static var allCases: [ScheduleDataModel.RepeatFrequency] {
            return [.daily, .weekly, .fortnightly, .monthly, .yearly, .customDays(days: [])]
        }
        
        var id: Int {
            switch self {
            case .never:
                return 0
            case .daily:
                return 1
            case .weekly:
                return 2
            case .fortnightly:
                return 3
            case .monthly:
                return 4
            case .yearly:
                return 5
            case .customDays:
                return 6
            }
        }
        
        var intValues: [Int] {
            switch self {
            case .never:
                return [0]
            case .daily:
                return [1]
            case .weekly:
                return [2]
            case .fortnightly:
                return [3]
            case .monthly:
                return [4]
            case .yearly:
                return [5]
            case .customDays(let days):
                return days.map(\.rawValue)
            }
        }
        
        var title: String? {
            switch self {
            case .daily:
                return "Daily"
            case .never:
                return nil
            case .weekly:
                return "Weekly"
            case .fortnightly:
                return "Fortnightly"
            case .monthly:
                return "Monthly"
            case .yearly:
                return "Yearly"
            case .customDays(let days):
                return "Every \(days.map { $0.title}.joined(separator: ", "))"
            }
        }
        
        var name: String? {
            switch self {
            case .customDays:
                return "Custom"
            default:
                return self.title
            }
        }
        
        var allCustomDays: [DayDataModel] {
            switch self {
            case .customDays:
                return DayDataModel.allCases
            default:
                return []
            }
        }
        
        var isCustomDays: Bool {
            switch self {
            case .customDays:
                return true
            default:
                return false
            }
        }
        
        var getCustomDaysIfAvailable: [DayDataModel] {
            switch self {
            case .customDays(let days):
                return days
            default:
                return []
            }
        }
        
        var isValid: Bool {
            switch self {
            case .customDays(let days):
                return !days.isEmpty
            default:
                return true
            }
        }
        
        var isNever: Bool {
            switch self {
            case .never:
                return true
            default:
                return false
            }
        }
        
        static func == (lhs: RepeatFrequency, rhs: RepeatFrequency) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    let id: String
    let title: String
    let description: String?
    let template: TemplateDataModel
    let scheduleDate: Date
    let repeatFrequency: RepeatFrequency
    
    static func == (lhs: ScheduleDataModel, rhs: ScheduleDataModel) -> Bool {
        lhs.id ==  rhs.id
    }
}
