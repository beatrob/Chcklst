//
//  ViewVisibility.swift
//  checklist
//
//  Created by Róbert Konczi on 15/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI

private struct FullWidthActionButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 48)
            .foregroundColor(configuration.role == .cancel ? Color.red : .firstAccent)
            .background(Color.firstAccent.opacity(configuration.isPressed ? 0.2 : 0.1))
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(Color.firstAccent.opacity(0.25))
            }
    }
}

struct BottomActionSheet<Actions: View>: View {

    @Environment(\.dismiss) private var dismiss
    let title: String
    private let actions: Actions

    init(title: String, @ViewBuilder actions: () -> Actions) {
        self.title = title
        self.actions = actions()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 4)

                actions
                    .buttonStyle(FullWidthActionButtonStyle())
                    .frame(maxWidth: .infinity)

                Button("Cancel", role: .cancel) { dismiss() }
                    .buttonStyle(FullWidthActionButtonStyle())
                    .frame(maxWidth: .infinity)
                    .padding(.top, 25)
            }
            
            .padding()
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

class ViewVisibility<SomeView>: ObservableObject, Equatable {
    
    @Published var isVisible = false
    
    var view: SomeView
    
    init(view: SomeView) {
        self.view = view
    }
    
    func set(view: SomeView, isVisible: Bool) {
        self.view = view
        self.isVisible = isVisible
    }
    
    static func == (lhs: ViewVisibility<SomeView>, rhs: ViewVisibility<SomeView>) -> Bool {
        lhs.isVisible == rhs.isVisible
    }
}
