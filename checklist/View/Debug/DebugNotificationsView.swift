//
//  DebugNotificationsView.swift
//  checklist
//
//  Created by Robert Konczi on 11/14/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct DebugNotificationsView: View {
    
    @StateObject var viewModel: DebugNotificationsViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                ForEach(viewModel.cells) {
                    DebugCellView(viewModel: $0)
                }
            }
        }
        .navigationTitle("Pending Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .chcklstNavigationBar()
    }
}

struct DebugNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        DebugNotificationsView(
            viewModel: .init(
                notificationManager: NotificationManager(checklistDataSource: MockChecklistDataSource())
            )
        )
    }
}
