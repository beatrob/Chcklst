//
//  CreateUpdateChecklistViewMode+Input.swift
//  checklist
//
//  Created by Róbert Konczi on 13/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation


enum ChecklistViewState {
    
    case display(checklist: ChecklistDataModel)
    case createTemplateFromChecklist(checklist: ChecklistDataModel)
    case createTemplate
    case updateTemplate(template: TemplateDataModel)
    case updateChecklist(checklist: ChecklistDataModel)
    case createChecklist
    case createChecklistFromTemplate(template: TemplateDataModel)
    
    var isDisplay: Bool {
        switch self {
        case .display:
            return true
        default:
            return false
        }
    }
    
    var isUpdate: Bool {
        switch self {
        case .updateChecklist:
            return true
        default:
            return false
        }
    }
    
    var isCreateFromTemplate: Bool {
        switch self {
        case .createChecklistFromTemplate:
            return true
        default:
            return false
        }
    }
    
    var isCreateChecklist: Bool {
        switch self {
        case .createChecklist, .createChecklistFromTemplate:
            return true
        default:
            return false
        }
    }
    
    var isCreateTemplate: Bool {
        switch self {
        case .createTemplateFromChecklist, .createTemplate:
            return true
        default:
            return false
        }
    }
    
    var isUpdateTemplate: Bool {
        switch self {
        case .updateTemplate:
            return true
        default:
            return false
        }
    }
    
    var template: TemplateDataModel? {
        switch self {
        case .createChecklistFromTemplate(let template), .updateTemplate(let template):
            return template
        default:
            return nil
        }
    }
    
    var checklist: ChecklistDataModel? {
        switch self {
        case .updateChecklist(let checklist), .display(let checklist), .createTemplateFromChecklist(let checklist):
            return checklist
        default:
            return nil
        }
    }
    
    var isEditEnabled: Bool {
        switch self {
        case .display:
            return false
        default:
            return true
        }
    }
}
