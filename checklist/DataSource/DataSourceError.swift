//
//  DataSourceError.swift
//  checklist
//
//  Created by Róbert Konczi on 16/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation


enum DataSourceError: Error {
    case checkListNotFound
    case checklistUpdateInMemoryFailed
    case templateNotFound
    case checkListItemNotFound
    case persitentStorageError(error: Error)
}
