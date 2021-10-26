//
//  Haptics.swift
//  checklist
//
//  Created by Robert Konczi on 10/24/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation
import UIKit

struct Haptics {
    
    enum FeedbackStyle : Int {
        case actionSheet
        case itemDoneUndone
        
        var uiFeedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
            case .actionSheet:
                return .rigid
            case .itemDoneUndone:
                return .heavy
            }
        }
    }
    
    enum FeedbackType : Int {
        case success = 0
        case warning = 1
        case error = 2
        
        var uiFeedbackType: UINotificationFeedbackGenerator.FeedbackType? {
            .init(rawValue: rawValue)
        }
    }

    static func play(_ feedbackStyle: FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle.uiFeedbackStyle).impactOccurred()
    }
    
    static func notify(_ feedbackType: FeedbackType) {
        guard let uiFeedbackType = feedbackType.uiFeedbackType else {
            return
        }
        UINotificationFeedbackGenerator().notificationOccurred(uiFeedbackType)
    }
}
