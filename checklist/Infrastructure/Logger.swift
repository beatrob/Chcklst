//
//  Logger.swift
//  checklist
//
//  Created by Róbert Konczi on 11/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import XCGLogger

func log(debug: String) {
    Logger.log.debug(debug)
}

func log(warning: String) {
    Logger.log.warning(warning)
}

func log(error: String) {
    Logger.log.error(error)
}

enum Logger {
    
    static let log = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: true)
    
    static func setup() {
        setupSystemDestinationLog()
    }
    
    static func setupSystemDestinationLog() {
        let systemDestination = AppleSystemLogDestination(identifier: "advancedLogger.systemDestination")
        systemDestination.outputLevel = .debug
        systemDestination.showLogIdentifier = false
        systemDestination.showFunctionName = true
        systemDestination.showThreadName = true
        systemDestination.showLevel = true
        systemDestination.showFileName = true
        systemDestination.showLineNumber = true
        systemDestination.showDate = true
        log.add(destination: systemDestination)
    }
}
