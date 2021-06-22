//
//  EmptyListView.swift
//  checklist
//
//  Created by Robert Konczi on 6/16/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI
import Combine

struct EmptyListView: View {
    
    let message: String
    let actionTitle: String
    let onActionTappedSubject: EmptySubject
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text(message)
                .modifier(Modifier.Checklist.Description())
                .multilineTextAlignment(.center)
                .padding()
            Button(
                action: {
                    onActionTappedSubject.send()
                }, label: {
                    Text(actionTitle)
                }
            )
            .padding()
            .modifier(Modifier.Button.MainAction())
            Spacer()
            Spacer()
        }
    }
}


struct EmptyListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyListView(
            message: "Your cool list is empty, and something else too.\nDo something good",
            actionTitle: "Create new",
            onActionTappedSubject: .init()
        )
    }
}
