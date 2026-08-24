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
        case monthly
        case yearly
        
        static var allCases: [ScheduleDataModel.RepeatFrequency] {
            return [.daily, .weekly, .monthly, .yearly, .customDays(days: [])]
        }
        
        var id: Int {
            switch self {
            case .never:
                return 0
            case .daily:
                return 1
            case .weekly:
                return 2
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
            case .monthly:
                return [4]
            case .yearly:
                return [5]
            case .customDays(let days):
                return days.map(\.index)
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
            case .monthly:
                return "Monthly"
            case .yearly:
                return "Yearly"
            case .customDays(let days):
                return "Every \(days.sorted { $0.rawValue < $1.rawValue }.map { $0.title}.joined(separator: ", "))"
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
        
        init?(rawValue: Int) {
            switch rawValue {
            case 0:
                self = .never
            case 1:
                self = .daily
            case 2:
                self = .weekly
            case 4:
                self = .monthly
            case 5:
                self = .yearly
            case 6:
                self = .customDays(days: [])
            default:
                return nil
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

    func matchesSearchText(_ searchText: String) -> Bool {
        guard !searchText.isEmpty else { return true }
        let lowercasedSearchText = searchText.lowercased()
        if title.lowercased().contains(lowercasedSearchText) ||
            description?.lowercased().contains(lowercasedSearchText) == true {
            return true
        }

        return Self.searchDateFormatters.contains {
            $0.string(from: scheduleDate).lowercased().contains(lowercasedSearchText)
        }
    }
    
    func copy(
        with title: String,
        description: String?,
        scheduleDate: Date,
        repeatFrequency: ScheduleDataModel.RepeatFrequency
    ) -> ScheduleDataModel {
        .init(
            id: self.id,
            title: title,
            description: description,
            template: self.template,
            scheduleDate: scheduleDate,
            repeatFrequency: repeatFrequency
        )
    }
}

private extension ScheduleDataModel {

    static let searchDateFormatters: [DateFormatter] = {
        let dateFormats = [
            "MMMM", "MMM", "EEEE", "EEE",
            "MMMM d", "MMM d", "d MMMM", "d MMM",
            "MMMM d yyyy", "MMM d yyyy", "d MMMM yyyy", "d MMM yyyy",
            "M/d", "MM/dd", "d/M", "dd/MM",
            "M.d", "MM.dd", "d.M", "dd.MM",
            "M-d", "MM-dd", "d-M", "dd-MM",
            "M/d/yyyy", "MM/dd/yyyy", "d/M/yyyy", "dd/MM/yyyy",
            "M.d.yyyy", "MM.dd.yyyy", "d.M.yyyy", "dd.MM.yyyy",
            "M-d-yyyy", "MM-dd-yyyy", "d-M-yyyy", "dd-MM-yyyy",
            "yyyy-MM-dd", "yyyy/MM/dd", "yyyy.MM.dd"
        ]
        let timeFormats = [
            "H:mm", "HH:mm", "H.mm", "HH.mm",
            "h:mm a", "hh:mm a", "h.mm a", "hh.mm a",
            "H:mm:ss", "HH:mm:ss", "h:mm:ss a", "hh:mm:ss a"
        ]
        let locales = [Locale.autoupdatingCurrent, Locale(identifier: "en_US_POSIX")]
        var formatters = locales.flatMap { locale in
            (dateFormats + timeFormats).map { format in
                let formatter = DateFormatter()
                formatter.locale = locale
                formatter.dateFormat = format
                return formatter
            }
        }

        let styles: [DateFormatter.Style] = [.short, .medium, .long, .full]
        formatters += locales.flatMap { locale in
            styles.flatMap { dateStyle in
                styles.map { timeStyle in
                    let formatter = DateFormatter()
                    formatter.locale = locale
                    formatter.dateStyle = dateStyle
                    formatter.timeStyle = timeStyle
                    return formatter
                }
            } + styles.flatMap { style in
                let dateFormatter = DateFormatter()
                dateFormatter.locale = locale
                dateFormatter.dateStyle = style

                let timeFormatter = DateFormatter()
                timeFormatter.locale = locale
                timeFormatter.timeStyle = style
                return [dateFormatter, timeFormatter]
            }
        }

        return formatters
    }()
}
