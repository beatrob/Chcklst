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
        let color = getForegroundColor(for: configuration.role)
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 48)
            .foregroundColor(color)
            .background(color.opacity(configuration.isPressed ? 0.2 : 0.1))
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(color.opacity(0.25))
            }
    }
    
    private func getForegroundColor(for role: ButtonRole?) -> Color {
        guard let role else {
            return .firstAccent
        }
        return switch role {
        case .cancel: .text
        case .destructive: .red
        default: .firstAccent
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
        .presentationDetents([.medium])
        .presentationBackground(Color.checklistBackground)
        .presentationDragIndicator(.hidden)
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
