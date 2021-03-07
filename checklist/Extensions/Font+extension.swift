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
    
    enum Chcklst {
        
        static let regular = "Avenir Next"
        static let bold = "Avenir Next Bold"
        
        case smallTitle
        case bigTitle
        case item
        case boldItem
        
        var font: Font {
            switch self {
            case .item:
                return Font.custom(Chcklst.regular, size: 15)
            case .boldItem:
                return Font.custom(Chcklst.bold, size: 15)
            case .smallTitle:
                return Font.custom(Chcklst.bold, size: 20)
            case .bigTitle:
                return Font.custom(Chcklst.bold, size: 24)
            }
        }
        
        var uiFont: UIFont {
            switch self {
            case .item:
                return UIFont(name: Chcklst.regular, size: 15)!
            case .boldItem:
                return UIFont(name: Chcklst.bold, size: 15)!
            case .smallTitle:
                return UIFont(name: Chcklst.bold, size: 20)!
            case .bigTitle:
                return UIFont(name: Chcklst.bold, size: 24)!
            }
        }
    }
}
