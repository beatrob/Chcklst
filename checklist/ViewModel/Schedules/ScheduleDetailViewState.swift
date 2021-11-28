//
//  ScheduleDetailViewState.swift
//  checklist
//
//  Created by Robert Konczi on 5/20/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation


enum ScheduleDetailViewState {
    
    case create(template: TemplateDataModel)
    case update(schedule: ScheduleDataModel)
    
    var title: String {
        switch self {
        case .create(let template):
            return template.title
        case .update(let schedule):
            return schedule.title
        }
    }
    
    var description: String? {
        switch self {
        case .create(let template):
            return template.description
        case .update(let schedule):
            return schedule.description
        }
    }
    
    var items: [ChecklistItemViewModel] {
        switch self {
        case .create(let template):
            return template.items.map {
                ChecklistItemViewModel(
                    item: $0.getUnDoneCopy(),
                    isEditable: false,
                    isCheckable: false,
                    itemDataSource: AppContext.resolver.resolve(ItemDataSource.self)!
                )
            }
        case .update(let schedule):
            return schedule.template.items.map {
                ChecklistItemViewModel(
                     item: $0.getUnDoneCopy(),
                     isEditable: false,
                     isCheckable: false,
                     itemDataSource: AppContext.resolver.resolve(ItemDataSource.self)!
                )
            }
        }
    }
    
    var isRepeatOn: Bool {
        switch self {
        case .create:
            return false
        case .update(let schedule):
            switch schedule.repeatFrequency {
            case .never:
                return false
            default:
                return true
            }
        }
    }
    
    var actionButtonTitle: String {
        switch self {
        case .create:
            return "Create"
        case .update:
            return "Update"
        }
    }
    
    var isCreate: Bool {
        switch self {
        case .create:
            return true
        default:
            return false
        }
    }
    
    var isUpdate: Bool {
        switch self {
        case .update:
            return true
        default:
            return false
        }
    }
    
    var template: TemplateDataModel? {
        switch self {
        case .create(let template):
            return template
        default:
            return nil
        }
    }
    
    var schedule: ScheduleDataModel? {
        switch self {
        case .update(let schedule):
            return schedule
        default:
            return nil
        }
    }
}
