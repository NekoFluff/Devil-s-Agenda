//
//  Constants.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/13/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit

struct Constants {
    
    struct NotificationKeys {
        static let SignedIn = "onSignInCompleted"
    }
    
    struct Segues {
        static let SignIn = "SignIn"
        static let AddClassVC = "AddClassVC"
        static let AddTaskVC = "AddTaskVC"
        static let EditClassVC = "EditClassVC"
    }
    
    struct ClassFields {
        static let name = "name"
        static let color = "color"
        static let owner = "owner"
        static let tasks = "tasks"
        static let shared = "shared"
        static let key = "key"
    }
    
    struct TaskFields {
        static let category = "category"
        static let description = "desc"
        static let dueDate = "dueDate"
        static let todoDate = "todoDate"
        static let key = "key"
    }
    
    struct FollowedClassFields {
        static let tasks = "tasks"
        static let owner = "owner"
    }
    
    static func uicolorForString(str: String) -> UIColor {
        switch (str) {
        case "Red":
            return UIColor.red
        case "Green":
            return UIColor.green
        case "Blue":
            return UIColor.blue
        case "Orange":
            return UIColor.orange
        case "Yellow":
            return UIColor.yellow
        case "Black":
            return UIColor.black
        default:
            return UIColor.black
        }
    }
}
