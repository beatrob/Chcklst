//
//  Modifiers.swift
//  checklist
//
//  Created by Róbert Konczi on 15.02.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI


enum Modifier {
    
}

extension Modifier {

    enum MainList {

        private static let horizontalInset: CGFloat = 20
        private static let verticalMargin: CGFloat = 16
        private static let rowSpacing: CGFloat = 16
        private static let cardContentInset: CGFloat = 16
        private static let cardCornerRadius: CGFloat = 20
        private static let cardBorderOpacity = 0.2
        private static let cardBorderWidth: CGFloat = 1

        struct Row: ViewModifier {

            let backgroundColor: Color

            func body(content: Content) -> some View {
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .listRowInsets(
                        EdgeInsets(
                            top: 0,
                            leading: MainList.horizontalInset,
                            bottom: 0,
                            trailing: MainList.horizontalInset
                        )
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(backgroundColor)
            }
        }

        struct Container: ViewModifier {

            func body(content: Content) -> some View {
                content
                    .listStyle(.plain)
                    .listRowSpacing(MainList.rowSpacing)
                    .contentMargins(.vertical, MainList.verticalMargin, for: .scrollContent)
                    .scrollContentBackground(.hidden)
                    .background(Color.mainBackground)
                    .environment(\.defaultMinListRowHeight, 1)
            }
        }

        struct CardContent: ViewModifier {

            let edges: Edge.Set

            func body(content: Content) -> some View {
                content.padding(edges, MainList.cardContentInset)
            }
        }

        struct Card: ViewModifier {

            let backgroundColor: Color

            func body(content: Content) -> some View {
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(backgroundColor)
                    .clipShape(.rect(cornerRadius: MainList.cardCornerRadius))
                    .overlay {
                        RoundedRectangle(cornerRadius: MainList.cardCornerRadius)
                            .strokeBorder(
                                Color.gray.opacity(MainList.cardBorderOpacity),
                                lineWidth: MainList.cardBorderWidth
                            )
                    }
                    .contentShape(.rect(cornerRadius: MainList.cardCornerRadius))
            }
        }
    }
}

extension View {

    func mainListRow(backgroundColor: Color = .clear) -> some View {
        modifier(Modifier.MainList.Row(backgroundColor: backgroundColor))
    }

    func mainListStyle() -> some View {
        modifier(Modifier.MainList.Container())
    }

    func mainListCardPadding(_ edges: Edge.Set = .all) -> some View {
        modifier(Modifier.MainList.CardContent(edges: edges))
    }

    func mainListCard(backgroundColor: Color) -> some View {
        modifier(Modifier.MainList.Card(backgroundColor: backgroundColor))
    }
}
