//
//  ReminderViewController.swift
//  DevilsAgenda
//
//  Created by Nicholas Jorgensen on 11/4/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit
import UserNotifications

protocol AddReminderDelegate {
    func addedNewReminder(_ r : Reminder);
}

class ReminderViewController: UIViewController {
    
    var delegate : AddReminderDelegate?;
    
    var task : Task!
    @IBOutlet weak var reminderTitle: UITextField!
    @IBOutlet weak var reminderDescription: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setReminder(_ sender: UIButton) {
        
        if (reminderTitle.text == "") {
            
            print("Set Reminder Title first!")
            
            let alertController = UIAlertController(title: "Wait", message: "Give your reminder a title first!", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        else if (reminderDescription.text == "") {
            
            print("Set Reminder Description first!")
            
            let alertController = UIAlertController(title: "Wait", message: "Give your reminder a description first!", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        else {
            
            //Create Reminder object
            let reminder = Reminder(task: task, date: datePicker.date, title: reminderTitle.text ?? "", description: reminderDescription.text ?? "")
            
            //Store in Task
            //task.addReminder(rem)
            
            //Signal delegate
            delegate?.addedNewReminder(reminder)
            
            //Dismiss
            dismiss(animated: true, completion: nil)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.reminderDescription.text = task.rClass.name
        self.datePicker.minimumDate = Date().add(components: [Calendar.Component.minute : 1])
        
        self.reminderTitle.delegate = self
        self.reminderDescription.delegate = self
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
    
    //DONE - TODO: When adding a reminder, save the reminder to the database. (WRITE)
    //DONE - TODO: When loading in each task, create any associated reminder (READ)
    //DONE - TODO: Table of reminders (under 'Add Reminder' button) in AddReminderViewController (VISUAL REPRESENTATION)
    //DONE - TODO: Add ability to delete reminders (DELETE)
    //DONE - TODO: Add ability to modify reminders? (MAYBE?)
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ReminderViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let set = NSCharacterSet(charactersIn: "ABCDEFGHIJKLMONPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789- !?#").inverted
        return (string.rangeOfCharacter(from: set) == nil)
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
}
