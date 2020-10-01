//
//  MyTemplatesView.swift
//  checklist
//
//  Created by Róbert Konczi on 30/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct SelectTemplateView: View {
    
    @ObservedObject var viewModel: SelectTemplateViewModel
    @EnvironmentObject var navigationHelper: NavigationHelper
    
    var body: some View {
        NavigationView {
            VStack {
                
                NavigationLink(
                    destination: navigationHelper.selectTemplateDestination,
                    tag: .createChecklist,
                    selection: $navigationHelper.selectTemplateSelection
                ) {
                    EmptyView()
                }
                .isDetailLink(false)
                .hidden()
                
                ForEach(
                    viewModel.templates,
                    id: \.id) { template in
                        MyTemplateItemView(
                            name: template.title,
                            description: template.description,
                            displayRightArrow: true
                        )
                            .onTapGesture {
                                self.viewModel.onTemplateTapped.send(template)
                        }
                }
                Spacer()
            }
            .navigationBarTitle("Select template", displayMode: .large)
        }
    }
}

struct SelectTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        SelectTemplateView(
            viewModel: .init(
                checklistDataSource: MockChecklistDataSource(),
                templateDataSource: MockTemplateDataSource(),
                navigationHelper: NavigationHelper()
            )
        )
    }
}
