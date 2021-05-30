//
//  RepeatFrequencyMO.swift
//  checklist
//
//  Created by Robert Konczi on 5/30/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import CoreData

@objc(RepeatFrequencyMO)
public class RepeatFrequencyMO: NSManagedObject {

}

extension RepeatFrequencyMO {

    @NSManaged public var identifier: Int32
    @NSManaged public var schedules: NSSet?
}
