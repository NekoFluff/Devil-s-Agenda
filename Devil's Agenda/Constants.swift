//
//  Constants.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/13/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//


struct Constants {
    
    struct NotificationKeys {
        static let SignedIn = "onSignInCompleted"
    }
    
    struct Segues {
        static let SignIn = "SignIn"
        static let AddClassVC = "AddClassVC"
        static let AddTaskVC = "AddClassVC"
    }
    
    struct ClassFields {
        static let name = "name"
        static let color = "color"
        static let tasks = "tasks"
        static let key = "key"
    }
    
    struct TaskFields {
        static let category = "category"
        static let description = "desc"
        static let dueDate = "dueDate"
        static let todoDate = "todoDate"
        static let key = "key"
    }
}
