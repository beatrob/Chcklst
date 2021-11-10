//
//  ScheduleCellView.swift
//  checklist
//
//  Created by Robert Konczi on 5/5/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct ScheduleCellView: View {
    
    @ObservedObject var viewModel: ScheduleCellViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Text(viewModel.title)
                        .modifier(Modifier.Schedule.SmallTitle())
                        .padding(.top)
                    Spacer()
                }
                viewModel.description.map {
                    Text($0)
                        .modifier(Modifier.Schedule.Description())
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .modifier(Modifier.Schedule.Description())
                    Text(viewModel.scheduleDate)
                        .modifier(Modifier.Schedule.ScheduleDate())
                }
                viewModel.repeatFrequency.map { freq in
                    HStack {
                        Image(systemName: "repeat")
                            .modifier(Modifier.Schedule.Description())
                        Text(freq)
                            .modifier(Modifier.Schedule.ScheduleDate())
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            
        }
        .background(Color.scheduleBackground)
        .cornerRadius(20)
        .contentShape(Rectangle())
    }
}

struct ScheduleCellView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleCellView(
            viewModel: .init(schedule: MockScheduleDataSource.mockData[0])
        ).previewLayout(.sizeThatFits)
    }
}
