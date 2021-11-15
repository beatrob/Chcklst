//
//  NotificationDataModel.swift
//  checklist
//
//  Created by Robert Konczi on 11/14/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation


struct NotificationDataModel {
    
    let id: String
    let title: String
    let nextTriggerDate: Date?
    let isRepeat: Bool
    let timeInterval: TimeInterval?
    let dateComponents: DateComponents?
}
