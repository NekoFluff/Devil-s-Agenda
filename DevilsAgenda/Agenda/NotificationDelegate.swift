//
//  NotificationDelegate.swift
//  DevilsAgenda
//
//  Created by Nicholas Jorgensen on 11/3/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) { //notifications delivered to foreground
        
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) { //user interaction with actions
        
        // Determine user action:
        
        switch response.actionIdentifier {
            
        case UNNotificationDismissActionIdentifier:
            //User swipes to dismiss notification
            print("Dismiss Notification")
        case UNNotificationDefaultActionIdentifier:
            //User taps on notification
            print("Tapped on Notification")
        case "SnoozeAction":
            //Set notification to go off again in snoozeLengthSec seconds
            print("Snooze")
        case "TaskCompleteAction":
            //Set the task associated with the notification to completed
            print("Task Complete!")
        default:
            print("Unknown Action")
            
        }
        
        completionHandler()
    }
}
