//
//  MyTemplatesView.swift
//  checklist
//
//  Created by Róbert Konczi on 30/08/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct MyTemplatesView: View {
    
    @ObservedObject var viewModel: MyTemplatesViewModel
    @EnvironmentObject var navigationHelper: NavigationHelper
    
    var body: some View {
        VStack {
            ForEach(
                viewModel.templates,
                id: \.id) { template in
                    MyTemplateItemView(
                        name: template.title,
                        description: template.description
                    )
                    .onTapGesture {
                        self.viewModel.onTemplateTapped.send(template)
                    }
            }
            Spacer()
        }
        .navigationBarTitle("My templates", displayMode: .large)
        .sheet(isPresented: $viewModel.isSheetVisible) {
            self.viewModel.sheetView
        }
        .actionSheet(isPresented: $viewModel.isActionSheetVisible) {
            self.viewModel.actionSheetView
        }
        .alert(isPresented: $viewModel.isAlertVisible) {
            self.viewModel.alertView
        }
    }
}

struct MyTemplatesView_Previews: PreviewProvider {
    static var previews: some View {
        MyTemplatesView(
            viewModel: .init(
                templateDataSource: MockTemplateDataSource(),
                checklistDataSource: MockChecklistDataSource(),
                navigationHelper: NavigationHelper()
            )
        )
    }
}
