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
        static let FinishedLoading = "FinishedLoading"
        static let AddClassVC = "AddClassVC"
        static let AddTaskVC = "AddTaskVC"
        static let EditClassVC = "EditClassVC"
        static let AddReminderVC = "AddReminderVC"
    }
    
    struct ClassFields {
        static let name = "name"
        static let color = "color"
        static let owner = "owner"
        static let tasks = "tasks"
        static let shared = "shared"
        static let key = "key"
        
        static let professor = "professor"
        static let location = "location"
        static let startTime = "startTime"
        static let endTime = "endTime"
        static let daysOfTheWeek = "daysOfTheWeek"
    }
    
    struct TaskFields {
        static let category = "category"
        static let description = "desc"
        static let dueDate = "dueDate"
        static let todoDate = "todoDate"
        static let key = "key"
        static let reminders = "reminders"
    }
    
    struct FollowedClassFields {
        static let tasks = "tasks"
        static let owner = "owner"
    }
    
    struct ReminderFields {
        static let date = "date"
        static let title = "title"
        static let description = "description"
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
