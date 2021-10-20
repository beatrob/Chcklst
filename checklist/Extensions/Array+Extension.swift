//
//  Array+Extension.swift
//  checklist
//
//  Created by Róbert Konczi on 16/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation


extension Array where Element == ChecklistItemDataModel {
    
    @discardableResult
    mutating func updateItem(_ item: Element) -> Bool {
        guard let index = firstIndex(of: item) else {
            return false
        }
        self.remove(at: index)
        self.insert(item, at: index)
        return true
    }
}

extension Array where Element == ChecklistDataModel {
    
    mutating func updateItem(_ item: Element) -> Bool {
        guard let index = firstIndex(of: item) else {
            return false
        }
        self.remove(at: index)
        self.insert(item, at: index)
        return true
    }
}
