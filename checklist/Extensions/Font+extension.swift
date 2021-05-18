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
        static let italic = "Avenir Next Italic"
        static let boldItalic = "Avenir Next Medium Italic"
        
        case smallTitle
        case bigTitle
        case item
        case boldItem
        case description
        case italicDescription
        
        var size: CGFloat {
            switch self {
            case .item, .boldItem:
                return 18
            case .description, .italicDescription:
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
            case .italicDescription:
                return getFont(name: Chcklst.boldItalic)
            }
        }
        
        var uiFont: UIFont {
            switch self {
            case .item, .description:
                return getUIFont(name: Chcklst.regular)
            case .boldItem, .smallTitle, .bigTitle:
                return getUIFont(name: Chcklst.bold)
            case .italicDescription:
                return getUIFont(name: Chcklst.boldItalic)
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
