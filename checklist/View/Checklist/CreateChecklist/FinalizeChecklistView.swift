//
//  FinalizeChecklistView.swift
//  checklist
//
//  Created by Róbert Konczi on 17/09/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct FinalizeChecklistView: View {
    
    @ObservedObject var viewModel: FinalizeChecklistViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Remind me on this device")
                Toggle(isOn: $viewModel.isReminderOn.animation()) {
                    EmptyView()
                }
            }.padding()
            if viewModel.isReminderOn {
                DatePicker(
                    selection: $viewModel.reminderDate,
                    displayedComponents: [.date, .hourAndMinute]
                ) {
                    EmptyView()
                }
            }
            CheckboxView(
                title: "Also save as template",
                isChecked: $viewModel.isCreateTemplateChecked
            ).padding()
            HStack {
                Spacer()
                Button("Create") {
                    self.viewModel.onCreate.send()
                }.padding()
                Spacer()
            }
        }
    }
}

struct FinalizeChecklistView_Previews: PreviewProvider {
    static var previews: some View {
        FinalizeChecklistView(
            viewModel: FinalizeChecklistViewModel()
        )
    }
}
