//
//  CreateUpdateChecklistViewMode+Input.swift
//  checklist
//
//  Created by Róbert Konczi on 13/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation


typealias ChecklistViewModelInput = ChecklistViewModel.Input

extension ChecklistViewModel {
    
    struct Input {

        enum Action {
            case display(checklist: ChecklistCurrentValueSubject)
            case update(checklist: ChecklistDataModel)
            case createFromTemplate(template: TemplateDataModel)
            case createNew
        }
        
        let createChecklistSubject: ChecklistPassthroughSubject
        let createTemplateSubject: TemplatePassthroughSubject
        let action: Action
        let isEditable: Bool
        
        var isDisplay: Bool {
            switch action {
            case .display:
                return true
            default:
                return false
            }
        }
        
        var isUpdate: Bool {
            switch action {
            case .update:
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
            case .update(let checklist):
                return checklist
            default:
                return nil
            }
        }
        
        var checklistSubject: ChecklistCurrentValueSubject? {
            switch action {
            case .display(let checklist):
                return checklist
            default:
                return nil
            }
        }
    }
}
