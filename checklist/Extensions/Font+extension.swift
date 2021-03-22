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
        case description
        
        var size: CGFloat {
            switch self {
            case .item, .boldItem:
                return 18
            case .description:
                return 18
            case .smallTitle:
                return 20
            case .bigTitle:
                return 36
            }
        }
        
        var font: Font {
            switch self {
            case .item, .description:
                return getFont(name: Chcklst.regular)
            case .boldItem, .smallTitle, .bigTitle:
                return getFont(name: Chcklst.bold)
            }
        }
        
        var uiFont: UIFont {
            switch self {
            case .item, .description:
                return getUIFont(name: Chcklst.regular)
            case .boldItem, .smallTitle, .bigTitle:
                return getUIFont(name: Chcklst.bold)
            }
        }
        
        private func getFont(name: String) -> Font {
            Font.custom(name, size: size)
        }
        
        private func getUIFont(name: String) -> UIFont {
            UIFont(name: name, size: size)!
        }
    }
}
