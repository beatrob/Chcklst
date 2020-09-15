//
//  String+Extension.swift
//  checklist
//
//  Created by Róbert Konczi on 15/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation


extension String {
    
    var nilWhenEmpty: String? {
        if self.isEmpty {
            return nil
        }
        return self
    }
}
