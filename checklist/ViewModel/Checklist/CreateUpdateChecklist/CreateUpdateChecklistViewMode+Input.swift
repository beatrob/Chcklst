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
    
    struct Input {

        enum Action {
            case updateChecklist(checklist: ChecklistDataModel)
            case createFromTemplate(template: TemplateDataModel)
            case createNew
        }
        
        let createChecklistSubject: ChecklistPassthroughSubject
        let createTemplateSubject: TemplatePassthroughSubject
        let action: Action
        
        var isUpdate: Bool {
            switch action {
            case .updateChecklist:
                return true
            default:
                return false
            }
        }
        
        var isCreateFromTemplate: Bool {
            switch action {
            case .createFromTemplate:
                return true
            default:
                return false
            }
        }
        
        var template: TemplateDataModel? {
            switch action {
            case .createFromTemplate(let template):
                return template
            default:
                return nil
            }
        }
        
        var checklistToUpdate: ChecklistDataModel? {
            switch action {
            case .updateChecklist(let checklist):
                return checklist
            default:
                return nil
            }
        }
    }
}
