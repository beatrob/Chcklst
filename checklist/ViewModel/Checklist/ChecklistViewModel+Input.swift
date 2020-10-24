//
//  CreateUpdateChecklistViewMode+Input.swift
//  checklist
//
//  Created by Róbert Konczi on 13/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation


typealias ChecklistViewModelInput = ChecklistViewModel.Input
typealias ChecklistViewState = ChecklistViewModel.Input.State

extension ChecklistViewModel {
    
    struct Input {

        enum State {
            case display(checklist: ChecklistDataModel)
            case update(checklist: ChecklistDataModel)
            case createFromTemplate(template: TemplateDataModel)
            case createNew
            
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
                case .update:
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
            
            var isCreateNew: Bool {
                switch self {
                case .createNew:
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
            
            var checklist: ChecklistDataModel? {
                switch self {
                case .update(let checklist), .display(let checklist):
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
        
        let createChecklistSubject: ChecklistPassthroughSubject
        let createTemplateSubject: TemplatePassthroughSubject
        let state: State
        let isEditable: Bool
        var template: TemplateDataModel? { state.template }
        var checklist: ChecklistDataModel? { state.checklist }
    }
}
