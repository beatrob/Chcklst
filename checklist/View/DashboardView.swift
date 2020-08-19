//
//  ContentView.swift
//  checklist
//
//  Created by Róbert Konczi on 10/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct DashboardView: View {
    
    @State var currentTag: Int?
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.checklists, id: \.id) { checklist in
                    VStack {
                        HStack {
                            Text(checklist.title).font(.title)
                            Spacer()
                            Text(checklist.counter).foregroundColor(.gray)
                        }
                        checklist.firstUndoneItem.map { first in
                            HStack {
                                ChecklistItemView(
                                    viewModel: self.viewModel.getItemViewModel(
                                        for: first,
                                        in: checklist
                                    )
                                )
                                Spacer()
                            }
                        }
                        NavigationLink(destination: self.viewModel.checklistDetail, tag: checklist.tag, selection: self.$viewModel.currentChecklistIndex) {
                            EmptyView()
                        }
                        .padding()
                        
                    }
                    
                }
            }
            .navigationBarTitle("My checklists")
            .navigationBarItems(
                trailing: Button.init(
                    action: { self.viewModel.onCreateNewChecklist.send()},
                    label: { Image(systemName: "plus") }
                )
            )
        }
        .sheet(isPresented: $viewModel.isSheetVisible) {
            CreateChecklistView(viewModel: self.viewModel.getCreateChecklistViewModel())
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
