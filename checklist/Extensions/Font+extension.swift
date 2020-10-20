//
//  Font+extension.swift
//  checklist
//
//  Created by Róbert Konczi on 19/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit


extension Font {
    
    enum AppFont {
        
        static let name = "Helvetica"
        
        case checklistTitle
        case checklistItem
        
        var font: Font {
            switch self {
            case .checklistItem:
                return Font.custom(AppFont.name, size: 20)
            case .checklistTitle:
                return Font.custom(AppFont.name, size: 36)
            }
        }
        
        var uiFont: UIFont {
            switch self {
            case .checklistItem:
                return UIFont(name: AppFont.name, size: 20)!
            default:
                return UIFont(name: AppFont.name, size: 36)!
            }
        }
    }
}
