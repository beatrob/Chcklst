//
//  ScheduleDetailView.swift
//  checklist
//
//  Created by Robert Konczi on 5/20/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct ScheduleDetailView: View {
    
    @StateObject var viewModel: ScheduleDetailViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ScheduleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleDetailView(
            viewModel: .init(
                state: .create(
                    template: .init(
                        id: "1",
                        title: "Some Template",
                        description: "This is a cool template for schedules",
                        items: [
                            .init(id: "1", name: "Item 1", isDone: false, updateDate: Date()),
                            .init(id: "2", name: "Item 2", isDone: false, updateDate: Date()),
                            .init(id: "3", name: "Item 3", isDone: false, updateDate: Date())
                        ]
                    )
                )
            )
        )
    }
}
