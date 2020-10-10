//
//  InitializeAppDataSource.swift
//  checklist
//
//  Created by Róbert Konczi on 10/10/2020.
//  Copyright © 2020 Róbert Konczi. All rights reserved.
//

import Foundation
import PromiseKit


protocol InitializeAppDataSource {
    func initializeApp() -> Promise<Void>
}


class InitializeAppDataSourceImpl: InitializeAppDataSource {
    
    let coreDataManager: CoreDataChecklistManager
    let userDefaults = UserDefaults.standard
    
    init(coreDataManager: CoreDataChecklistManager) {
        self.coreDataManager = coreDataManager
    }
    
    func initializeApp() -> Promise<Void> {
        guard !userDefaults.isAppInitialized else {
            return .value
        }
        return initializeWelcomeData()
            .get { self.userDefaults.setAppInitialized() }
    }
}


private extension InitializeAppDataSourceImpl {
    
    func initializeWelcomeData() -> Promise<Void> {
        let welcomeChecklist = ChecklistDataModel(
            id: UUID().uuidString,
            title: "Welcome",
            description: "Welcome to C H C K ✓ L S T, an app which helps you get things done using the power of checklist. By following this short tutorial you will learn all the cool things you can do with C H C K ✓ L S T",
            updateDate: Date(),
            items: [
                .init(
                    id: UUID().uuidString,
                    name: "Tap on the bullet, or swipe right on this title to make this done",
                    isDone: false,
                    updateDate: Date().addingTimeInterval(1)
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Start a new cheklist by tapping the + icon on the Dashboard",
                    isDone: false,
                    updateDate: Date().addingTimeInterval(2)
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Select \"Create new checklist\" to start a new checklist form scratch",
                    isDone: false,
                    updateDate: Date().addingTimeInterval(3)
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Select \"New from template\" to create a checklist from your saved tamplets",
                    isDone: false,
                    updateDate: Date().addingTimeInterval(4)
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Fill your new checklist with your TODO's",
                    isDone: false,
                    updateDate: Date().addingTimeInterval(5)
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Create a new template in addition to reuse your TODO list later",
                    isDone: false,
                    updateDate: Date().addingTimeInterval(6)
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Setup a reminder to notify you when to get things done",
                    isDone: false,
                    updateDate: Date().addingTimeInterval(7)
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Edit, delete, organize and do more with your checklist byt long-pressing the titles on the Dashboard",
                    isDone: false,
                    updateDate: Date().addingTimeInterval(8)
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Enjoy life! 🙂",
                    isDone: false,
                    updateDate: Date().addingTimeInterval(9)
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Tap on the checkmark, or swipe left on this title to make this undone",
                    isDone: true,
                    updateDate: Date().addingTimeInterval(10)
                )
            ]
        )
        return coreDataManager.save(checklist: welcomeChecklist)
    }
}
