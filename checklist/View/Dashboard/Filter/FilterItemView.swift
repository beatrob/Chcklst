//
//  FilterItemView.swift
//  checklist
//
//  Created by Róbert Konczi on 09/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct FilterItemView: View {
    
    let image: Image
    let isSelected: Bool
    let onTapped: EmptySubject
    
    var body: some View {
        ZStack {
            Capsule()
                .fill(isSelected ? Color.blue : Color.white)
                .background(
                    Capsule().stroke(isSelected ? Color.blue : Color.black, lineWidth: 1)
                )
            image.foregroundColor(isSelected ? Color.white : Color.black)
        }
        .frame(width: 40, height: 30)
        .onTapGesture {
            self.onTapped.send()
        }
    }
}

struct FilterItemView_Previews: PreviewProvider {
    static var previews: some View {
        FilterItemView(
            image: .init(systemName: "calendar.badge.clock"),
            isSelected: false,
            onTapped: .init()
        )
    }
}
