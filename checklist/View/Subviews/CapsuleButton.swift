//
//  CapsuleButton.swift
//  checklist
//
//  Created by Robert Konczi on 10/14/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI
import Combine

struct CapsuleButton: View {
    
    enum ButtonType {
        case primary
        case secondary
    }
    
    let title: String?
    let localizedKey: LocalizedStringKey?
    let type: ButtonType
    let onTapSubject: EmptySubject
    
    init(title: String, type: ButtonType, onTapSubject: EmptySubject) {
        self.title = title
        self.localizedKey = nil
        self.type = type
        self.onTapSubject = onTapSubject
    }
    
    init(localizedKey: LocalizedStringKey, type: ButtonType, onTapSubject: EmptySubject) {
        self.title = nil
        self.localizedKey = localizedKey
        self.type = type
        self.onTapSubject = onTapSubject
    }
    
    var body: some View {
        
        Button {
            onTapSubject.send()
        } label: {
            HStack {
                Spacer()
                if let title = self.title {
                    Text(title)
                } else if let localizedKey = localizedKey {
                    Text(localizedKey)
                }
                Spacer()
            }
        }.if(type == .primary) {
            $0.modifier(Modifier.Button.PrimaryAction())
        }.if(type == .secondary) {
            $0.modifier(Modifier.Button.SecondaryAction())
        }
    }
}

struct CapsuleButton_Previews: PreviewProvider {
    static var previews: some View {
        CapsuleButton(title: "Button test", type: .primary, onTapSubject: .init())
    }
}
