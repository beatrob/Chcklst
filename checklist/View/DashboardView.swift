//
//  ContentView.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct DashboardView: View {
    
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        List(viewModel.checklists, id: \.id) { checklist in
            VStack {
                HStack {
                    Text(checklist.title).font(.title)
                    Spacer()
                    Text(checklist.counter).foregroundColor(.gray)
                }
                HStack {
                    Image(systemName: "circle").foregroundColor(.gray)
                    Text(checklist.firstItem).font(.caption).foregroundColor(.gray)
                    Spacer()
                }
            }
            .padding()
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(
            viewModel: DashboardViewModel(checklistDataSource: MockChecklistDataSource())
        )
    }
}
