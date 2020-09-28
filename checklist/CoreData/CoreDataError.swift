//
//  CoreDataError.swift
//  checklist
//
//  Created by Róbert Konczi on 28/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation


enum CoreDataError: Error, LocalizedError {
    
    case nilViewContext
    case fetchError
    case createEntityError
    
    var localizedDescription: String {
        switch self {
        case .nilViewContext:
            return "ViewContext can not be nil"
        case .fetchError:
            return "Failed to fetch data"
        case .createEntityError:
            return "Failed to create Core Data entity"
        }
    }
}
