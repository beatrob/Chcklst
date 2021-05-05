//
//  SchedulesView.swift
//  checklist
//
//  Created by Robert Konczi on 5/5/21.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import SwiftUI

struct SchedulesView: View {
    
    @StateObject var viewModel: SchedulesViewModel
    
    var body: some View {
        VStack {
            BackButtonNavBar(viewModel: viewModel.navBarViewModel)
            Spacer()
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
    }
}

struct SchedulesView_Previews: PreviewProvider {
    static var previews: some View {
        SchedulesView(viewModel: .init())
    }
}
