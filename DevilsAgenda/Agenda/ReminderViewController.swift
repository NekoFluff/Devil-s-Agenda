//
//  ReminderViewController.swift
//  DevilsAgenda
//
//  Created by Nicholas Jorgensen on 11/4/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit
import UserNotifications

class ReminderViewController: UIViewController {
    
    var task : Task!
    @IBOutlet weak var reminderTitle: UITextField!
    @IBOutlet weak var reminderDescription: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setReminder(_ sender: UIButton) {
        
        if (reminderTitle.text == nil) {
            
            print("Set Reminder Title first!")
            
        }
        else if (reminderDescription.text == nil) {
            
            print("Set Reminder Description first!")
            
        }
        else {
            //Create Reminder object
            let rem = Reminder(date: datePicker.date, title: reminderTitle.text ?? "", description: reminderDescription.text ?? "")
            
            //Store in Task
            task.addReminder(rem)
            
            //identifier:
            let identifier = "reminder"
            
            //actions:
            let snoozeAction = UNNotificationAction(identifier: "SnoozeAction", title: "Snooze", options: [])
            let taskCompleteAction = UNNotificationAction(identifier: "TaskCompleteAction", title: "Mark Completed", options: [])
            
            //category:
            let category = UNNotificationCategory(identifier: "ReminderCategory", actions: [snoozeAction, taskCompleteAction], intentIdentifiers: [], options: [])
            
            //content:
            let content = UNMutableNotificationContent()
            content.title = reminderTitle.text!
            content.body = reminderDescription.text!
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = "ReminderCategory"
            
            //trigger:
                guard datePicker.date > Date() else {print("ERROR: Due date < current date"); return}
                
                let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: datePicker.date)
            
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                
                //Schedule notification:
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                AppDelegate().setDateNotification(category: category, request: request)
            
                print("Reminder Set!")
            
                dismiss(animated: true, completion: nil)
            
                //TODO: Have a visual identicator for the user to know their reminder was set in Add Task VC
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.reminderDescription.text = task.rClass.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //DONE - TODO: Create reminder object
    //DONE - TODO: Pass task into ReminderViewController
    //DONE - TODO: Add reminder object to task.
    
    //DONE - TODO: When program exits, send reminders to NotificationCenter
    //DONE - TODO: When program comes to foreground, remove all reminders
    
    //TODO: When adding a reminder, save the reminder to the database. (WRITE)
    //TODO: When loading in each task, create any associated reminder (READ)
    //TODO: Table of reminders (under 'Add Reminder' button) in AddReminderViewController (VISUAL REPRESENTATION)
    //TODO: Add ability to delete reminders (DELETE)
    //TODO: Add ability to modify reminders? (MAYBE?)
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
