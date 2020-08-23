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
        NavigationView {
            VStack {
                NavigationLink(destination: viewModel.checklistDetail, isActive: $viewModel.isCheklistDetailVisible) {
                    EmptyView()
                }.hidden()
                Spacer().frame(height: 15.0)
                ForEach(viewModel.checklists, id: \.id) { checklist in
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
                            Rectangle().frame(height: 0.5).foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .onTapGesture {
                            self.viewModel.onChecklistTapped.send(checklist)
                        }
                    .simultaneousGesture(LongPressGesture().onEnded({ _ in
                        self.viewModel.onChecklistLongTapped.send(checklist)
                    }))
                }
                Spacer()
            }
            .navigationBarTitle("C H C K ✓ L S T", displayMode: .inline)
            .navigationBarItems(
                leading: Button.init(
                    action: { self.viewModel.onSettings.send() },
                    label: { Image(systemName: "gear") }
                ),
                trailing: Button.init(
                    action: { self.viewModel.onCreateNewChecklist.send()},
                    label: { Image(systemName: "plus") }
                )
            )
        }
        .actionSheet(isPresented: $viewModel.isActionSheetVisible) {
            self.viewModel.actionSheetView
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
