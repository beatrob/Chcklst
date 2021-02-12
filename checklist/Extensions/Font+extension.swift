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
        
        static let name = "Avenir Next"
        static let boldName = "Avenir Next Bold"
        
        case checklistTitle
        case checklistItem
        
        var font: Font {
            switch self {
            case .checklistItem:
                return Font.custom(AppFont.name, size: 17)
            case .checklistTitle:
                return Font.custom(AppFont.boldName, size: 30)
            }
        }
        
        var uiFont: UIFont {
            switch self {
            case .checklistItem:
                return UIFont(name: AppFont.name, size: 17)!
            default:
                return UIFont(name: AppFont.boldName, size: 30)!
            }
        }
    }
}
