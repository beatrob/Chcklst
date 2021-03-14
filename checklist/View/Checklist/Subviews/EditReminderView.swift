//
//  EditReminderView.swift
//  checklist
//
//  Created by Róbert Konczi on 11.03.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct EditReminderView: View {
    
    @StateObject var viewModel: EditReminderViewModel
    
    var body: some View {
        ZStack {
            Color.checklistBackground.ignoresSafeArea()
            VStack(spacing: 30) {
                Text(viewModel.title)
                    .modifier(Modifier.Checklist.BigTitle())
                Image(systemName: "bell.badge.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.firstAccent)
                CheckboxView(
                    title: "Remind me on this device",
                    isChecked: $viewModel.isReminderOn.animation()
                ).padding()
                if viewModel.isReminderOn {
                    HStack {
                        Spacer()
                        DatePicker("",
                                   selection: $viewModel.reminderDate,
                                   displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                        Spacer()
                    }
                }
                Button("Save") {
                    viewModel.onSave.send()
                }.modifier(Modifier.Button.MainAction())
            }
        }
        .alert(isPresented: $viewModel.isAlertVisible) {
            viewModel.alert
        }
    }
}

struct EditReminderView_Previews: PreviewProvider {
    static var previews: some View {
        EditReminderView(
            viewModel: EditReminderViewModel(
                checklist: .getWelcomeChecklist(),
                notificationManager: NotificationManager()
            )
        )
    }
}
