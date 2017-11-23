//
//  NotificationsHandler.swift
//  DevilsAgenda
//
//  Created by Alexander Nou on 11/22/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationsHandler {
    static let defaultHandler = NotificationsHandler()
    
    let center = UNUserNotificationCenter.current()
    
    func setDateNotification(category: UNNotificationCategory, request: UNNotificationRequest) -> Void {
        
        print("Adding Notification to center")
        center.setNotificationCategories([category])
        
        center.add(request, withCompletionHandler: { (error) in
            if error != nil {
                //Something's wrong yo
                print("oh no")
            }
        })
        
        print("Content: \(request.content)")
        
        center.getPendingNotificationRequests(){ requests in
            for request in requests {
                guard let trigger = request.trigger as? UNCalendarNotificationTrigger else {return}
                print("Set alert at: \(Calendar.current.dateComponents([.year,.day,.month,.hour,.minute,.second], from: trigger.nextTriggerDate()!))")
            }
        }
        
    }
    
    func setReminders() {
        center.getNotificationSettings { (settings) in
            
            //Make sure the app are authorized
            if settings.authorizationStatus == .authorized {
                
                //Compact tasks
                let manager = DatabaseManager.defaultManager
                manager.tasks.compact()
                
                //Enumerate tasks
                for index in 0..<manager.tasks.count {
                    if let task = manager.tasks.object(at: index) as? Task {
                        
                        //Enumerate reminders
                        for reminder in task.reminders {
                            
                            let _ = self.setReminder(reminder);
                        }
                        
                        self.setTodo(task: task)
                    }
                }
            }
        }
    }
    
    public func setTodo(task: Task) {
        if let todoDate = task.todoDate {
            //identifier:
            let identifier = "todo---\(task.desc)"
            
            //actions:
            let snoozeAction = UNNotificationAction(identifier: "SnoozeAction", title: "Snooze", options: [])
            let taskCompleteAction = UNNotificationAction(identifier: "TaskCompleteAction", title: "Mark Completed", options: [])
            
            //category:
            let category = UNNotificationCategory(identifier: "ReminderCategory", actions: [snoozeAction, taskCompleteAction], intentIdentifiers: [], options: [])
            
            //content:
            let content = UNMutableNotificationContent()
            content.title = task.desc
            content.body = "Let's get to work!"
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "ReminderCategory"
            
            //trigger:
            guard todoDate > Date() else {print("ERROR: Due date < current date"); return}
            
            let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: todoDate)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            //Schedule notification:
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            self.setDateNotification(category: category, request: request)
        }
    }
    
    public func removeTodo(task: Task) {
        center.getPendingNotificationRequests { (notifications) in
            self.center.removePendingNotificationRequests(withIdentifiers: ["todo---\(task.desc)"])
        }
    }
    
    public func removeAllTodos() {
        center.getPendingNotificationRequests { (notifications) in
            var identifiers : [String] = []
            
            //Compact tasks
            let manager = DatabaseManager.defaultManager
            manager.tasks.compact()
            
            for index in 0..<manager.tasks.count {
                if let task = manager.tasks.object(at: index) as? Task {
                    
                    identifiers.append("todo---\(task.desc)")
                }
            }
            
            self.center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    public func setReminder(_ reminder: Reminder) -> Bool {
        //identifier:
        let identifier = reminder.title
        
        //actions:
        let snoozeAction = UNNotificationAction(identifier: "SnoozeAction", title: "Snooze", options: [])
        let taskCompleteAction = UNNotificationAction(identifier: "TaskCompleteAction", title: "Mark Completed", options: [])
        
        //category:
        let category = UNNotificationCategory(identifier: "ReminderCategory", actions: [snoozeAction, taskCompleteAction], intentIdentifiers: [], options: [])
        
        //content:
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.description
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "ReminderCategory"
        
        //trigger:
        guard reminder.date > Date() else {print("ERROR: Due date < current date"); return false}
        
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: reminder.date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        //Schedule notification:
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        self.setDateNotification(category: category, request: request)
        
        //Success!
        return true
    }
    
    func deleteReminders() {
        print("\n\nRemoving notifications")
        center.getPendingNotificationRequests { (notifications) in
            print("NOTIFICATIONS: \(notifications)")
            
            self.center.removePendingNotificationRequests(withIdentifiers: notifications.map({ (request) -> String in
                return request.identifier
            }))
        }
        print("Removed notifications\n\n")
    }
    
    public func deleteReminder(_ reminder : Reminder) {
        center.getPendingNotificationRequests { (notifications) in
            
            self.center.removePendingNotificationRequests(withIdentifiers: [reminder.title])
        }
    }

}
