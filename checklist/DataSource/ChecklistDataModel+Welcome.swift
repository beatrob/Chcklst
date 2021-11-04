//
//  ChecklistDataModel+Welcome.swift
//  checklist
//
//  Created by Róbert Konczi on 08.03.2021.
//  Copyright © 2021 Róbert Konczi. All rights reserved.
//

import Foundation


extension ChecklistDataModel {
    
    static func getWelcomeChecklist() -> Self {
        let now = Date()
        return ChecklistDataModel(
            id: UUID().uuidString,
            title: "Welcome",
            description: "Welcome to Chcklst, an app which helps you get things done using the power of checklist. By following this short tutorial you will learn all the cool things you can do 😉",
            creationDate: now,
            updateDate: now,
            reminderDate: nil,
            items: [
                .init(
                    id: UUID().uuidString,
                    name: "Tap on the bullet, or long-tap on this title to make this item done/un-done",
                    isDone: false,
                    updateDate: now.addingTimeInterval(1)
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Create a new Cheklist by tapping on the + icon on the Dashboard",
                    isDone: false,
                    updateDate: now.addingTimeInterval(2)
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Select \"Checklist\" to start a new checklist form scratch",
                    isDone: false,
                    updateDate: now.addingTimeInterval(3)
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Select \"Checklist from template\" to create a checklist from your saved tamplets",
                    isDone: false,
                    updateDate: now.addingTimeInterval(4)
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Fill your new Checklist with items",
                    isDone: false,
                    updateDate: now.addingTimeInterval(5)
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Create a new Template in addition to reuse your TODO list later",
                    isDone: false,
                    updateDate: now.addingTimeInterval(6)
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Setup a reminder to getr notified you when it's time to make things done",
                    isDone: false,
                    updateDate: now.addingTimeInterval(7)
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Edit, delete and do more with your Checklist byt long-pressing the titles on the Dashboard",
                    isDone: false,
                    updateDate: now.addingTimeInterval(8)
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Create Schedules from Templates to plan your Checklists ahead",
                    isDone: false,
                    updateDate: now.addingTimeInterval(9)
                ),
                .init(
                    id: UUID().uuidString,
                    name: "Enjoy life! 🙂",
                    isDone: false,
                    updateDate: now.addingTimeInterval(10)
                )
            ]
        )
    }
}
