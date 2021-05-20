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
}
