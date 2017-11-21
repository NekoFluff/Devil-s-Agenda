//
//  Reminder.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/13/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import Foundation

struct Reminder {
    var databaseKey : String?
    let date : Date
    let title : String
    let description : String
    unowned let task : Task
    
    init(task : Task, date : Date, title: String, description: String) {
        self.date = date
        self.title = title
        self.description = description
        self.task = task
        task.addReminder(self)
    }
    
    init(task: Task, data: [String : String], databaseKey : String?) {
        self.task = task
        self.databaseKey = databaseKey
        
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy HH:mm:ss"
        
        if let date = data[Constants.ReminderFields.date] {
            self.date = df.date(from : date) ?? Date()
        } else {
            self.date = Date()
        }
        
        if let title = data[Constants.ReminderFields.title] {
            self.title = title
        } else {
            self.title = "CORRUPTED TITLE"
        }
        
        if let description = data[Constants.ReminderFields.description] {
            self.description = description
        } else {
            self.description = "CORRUPTED DESCRIPTION"
        }
        
        task.addReminder(self)
    }
    
    func toDict() -> [String : String] {
        
        //Create date formatter
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy HH:mm:ss"
        
        //Create dictionary to store data in
        var dict = Dictionary<String, String>()
        
        //Add data
        dict[Constants.ReminderFields.title] = self.title
        dict[Constants.ReminderFields.description] = self.description
        
        let dateString = df.string(from: date)
        dict[Constants.ReminderFields.date] = dateString

        
        return dict
    }
}
