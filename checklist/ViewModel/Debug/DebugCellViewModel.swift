//
//  DubgCellViewModel.swift
//  checklist
//
//  Created by Robert Konczi on 11/14/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import OrderedCollections

class DebugCellViewModel: ObservableObject, Identifiable {
    
    let id: String
    @Published var title: String
    @Published var attributes: OrderedDictionary<String, String>
    
    init(id: String, title: String, attributes: OrderedDictionary<String, String>) {
        self.id = id
        self.title = title
        self.attributes = OrderedDictionary.init(uniqueKeys: attributes.keys, values: attributes.values)
    }
    
    convenience init(notification: NotificationDataModel) {
        var attributes = OrderedDictionary<String, String>()
        attributes["id"] = notification.id
        attributes["repeat"] = String(notification.isRepeat)
        if let date = notification.nextTriggerDate {
            attributes["next trigger date"] = String(describing: date)
        }
        if let timeInterval = notification.timeInterval {
            attributes["time interval"] = String(timeInterval)
        }
        if let dateComponents = notification.dateComponents {
            attributes["date components"] = String(describing: dateComponents)
        }
        self.init(id: notification.id, title: notification.title, attributes: attributes)
    }
}
