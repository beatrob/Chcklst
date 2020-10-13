//
//  CreateUpdateChecklistViewMode+Input.swift
//  checklist
//
//  Created by Róbert Konczi on 13/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation


typealias ChecklistViewModelInput = CreateUpdateChecklistViewModel.Input

extension CreateUpdateChecklistViewModel {
    
    enum Input {
        case updateChecklist(checklist: ChecklistDataModel)
        case createFromTemplate(template: TemplateDataModel)
        case none
        
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
            case .createFromTemplate:
                return true
            default:
                return false
            }
        }
        
        var template: TemplateDataModel? {
            switch self {
            case .createFromTemplate(let template):
                return template
            default:
                return nil
            }
        }
        
        var checklistToUpdate: ChecklistDataModel? {
            switch self {
            case .updateChecklist(let checklist):
                return checklist
            default:
                return nil
            }
        }
    }
}
