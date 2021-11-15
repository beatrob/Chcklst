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


typealias ChcklstFont = Font.Chcklst

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
        case bigDescription
        case bigItalicDescription
        case smallText
        
        var size: CGFloat {
            switch self {
            case .smallText:
                return 12
            case .item, .boldItem:
                return 18
            case .description, .italicDescription:
                return 18
            case .smallTitle:
                return 20
            case .bigDescription, .bigItalicDescription:
                return 24
            case .bigTitle:
                return 36
            }
        }
        
        var minimumTextFieldHeight: CGFloat {
            size + 22
        }
        
        var font: Font {
            switch self {
            case .item, .description, .smallText, .bigDescription:
                return getFont(name: Chcklst.regular)
            case .boldItem, .smallTitle, .bigTitle:
                return getFont(name: Chcklst.bold)
            case .italicDescription:
                return getFont(name: Chcklst.boldItalic)
            case .bigItalicDescription:
                return getFont(name: Chcklst.italic)
            }
        }
        
        var uiFont: UIFont {
            switch self {
            case .item, .description, .smallText, .bigDescription:
                return getUIFont(name: Chcklst.regular)
            case .boldItem, .smallTitle, .bigTitle:
                return getUIFont(name: Chcklst.bold)
            case .italicDescription:
                return getUIFont(name: Chcklst.boldItalic)
            case .bigItalicDescription:
                return getUIFont(name: Chcklst.italic)
            }
        }
        
        private func getFont(name: String) -> Font {
            Font.custom(name, size: size)
        }
        
        private func getUIFont(name: String) -> UIFont {
            UIFont(name: name, size: size)!
        }
        
        func getMinimumTextFieldHeight(for text: String, width: CGFloat) -> CGFloat {
            let size = text.boundingRect(
                with: .init(width: width, height: .greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: [.font: uiFont],
                context: nil
            )
            return size.height + 18
        }
    }
    
    
}
