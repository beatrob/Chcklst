//
//  Error+Extension.swift
//  checklist
//
//  Created by Róbert Konczi on 13/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation


extension Error {
    
    func log(message: String) {
        Logger.log.error("\(message) \(self.localizedDescription)")
    }
}
