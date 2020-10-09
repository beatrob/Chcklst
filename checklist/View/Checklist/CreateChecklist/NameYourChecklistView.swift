//
//  NameYourChecklistView.swift
//  checklist
//
//  Created by Róbert Konczi on 19/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI
import Combine

struct NameYourChecklistView: View {
    
    @Binding var checklistName: String
    @Binding var shouldCreateChecklistName: Bool
    let onNext: EmptySubject
    @State var textHeight: CGFloat = 150
    
    var body: some View {
        VStack(alignment: .center) {
            TextField("Name your new checklist", text: $checklistName, onCommit:  {
                withAnimation {
                    self.onNext.send()
                }
            })
            .font(.system(size: 38))
            .padding()
            if shouldCreateChecklistName {
                Button("Next") {
                    UIApplication.shared.endEditing()
                    withAnimation {
                        self.onNext.send()
                    }
                }
            }
        }
    }
}

struct NameYourChecklistView_Previews: PreviewProvider {
    @State var name: String
    static var previews: some View {
        NameYourChecklistView(
            checklistName: .init(get: { "" }, set: { _ = $0 }),
            shouldCreateChecklistName: .init(get: { true }, set: { _ = $0 }),
            onNext: .init()
        )
    }
}
