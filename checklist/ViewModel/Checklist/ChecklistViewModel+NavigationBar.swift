//
//  ChecklistViewModel+NavigationBar.swift
//  checklist
//
//  Created by Róbert Konczi on 24/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import SwiftUI


extension ChecklistViewModel {
    
    var navigationBarTrailingItem: AnyView {
        if viewState.isDisplay || viewState.isUpdate {
            return AnyView(
                !isEditable ?
                    Button("Edit") { self.onEditTapped.send() } :
                    Button("Done") { self.onDoneTapped.send() }
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    var navigationBarTitle: LocalizedStringKey {
        switch viewState {
        case .display:
            return LocalizedStringKey("")
        case .createFromTemplate, .createNew:
            return "Create checklist"
        case .update:
            return "Edit checklist"
        }
    }
    
    var titleDisplayMode: NavigationBarItem.TitleDisplayMode {
        return .inline
    }
}
