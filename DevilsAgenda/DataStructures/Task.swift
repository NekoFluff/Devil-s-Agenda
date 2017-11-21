//
//  Task.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/14/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import Foundation

enum taskCategory : String {
    case Assignment = "Assignment", Quiz = "Quiz", Test = "Test", Project = "Project", Other = "Other"
}

class Task : Equatable {
    
    unowned let rClass : Class
    var category : taskCategory?
    var desc : String = ""
    var dueDate : Date?
    var todoDate : Date?
    var databaseKey : String?
    var reminders : [Reminder] = []
    
    init(_ rClass: Class, category: taskCategory, desc : String, dueDate : Date? = nil, todoDate: Date? = nil) {
        self.rClass = rClass
        reconfigure(category: category, desc: desc, dueDate: dueDate, todoDate: todoDate)
    }
    
    init(_ rClass: Class, data: [String : Any], databaseKey: String) {
        self.rClass = rClass
        
        reconfigure(category: taskCategory(rawValue: data[Constants.TaskFields.category] as? String ?? "Assignment")!,
                    desc: (data[Constants.TaskFields.description]) as? String ?? "ERROR_DESC")
        
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy HH:mm:ss"
        
        if let date = data[Constants.TaskFields.dueDate] as? String {
            self.dueDate = df.date(from : date)
        }
        
        if let date = data[Constants.TaskFields.todoDate] as? String {
            self.todoDate = df.date(from : date)
        }
        
        if let remindersData = data[Constants.TaskFields.reminders] as? [[String : String]] {
            for (index, data) in remindersData.enumerated() {
                let _ = Reminder(task: self, data: data, databaseKey: "\(index)")
            }
        }
        
        self.databaseKey = databaseKey
    }
    
    
    
    func reconfigure(category: taskCategory, desc : String, dueDate : Date? = nil, todoDate: Date? = nil) {
        
        self.category = category
        self.desc = desc
        self.dueDate = dueDate
        self.todoDate = todoDate
    }
    
    func toDict() -> [String : Any?] {
        
        //Create date formatter
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy HH:mm:ss"
        
        //Create dictionary to store data in
        var dict = Dictionary<String, Any?>()
        
        //Add data
        if let category = category {
            dict[Constants.TaskFields.category] = category.rawValue
        }
        
        //Description
        dict[Constants.TaskFields.description] = self.desc
        
        if let dueDate = dueDate {
            let dateString = df.string(from: dueDate)
            dict[Constants.TaskFields.dueDate] = dateString
        }
        
        if let todoDate = todoDate {
            let dateString = df.string(from: todoDate)
            dict[Constants.TaskFields.todoDate] = dateString
        }

        dict[Constants.TaskFields.reminders] = reminders.map({ (reminder) -> [String:String] in
            return reminder.toDict()
        })


        
        return dict
    }
    
    deinit {
        print("De-allocating Task \(desc)")
    }
    
    func addReminder(_ r: Reminder) {
        self.reminders.append(r)
    }
    
    static func ==(left: Task, right: Task) -> Bool {
        return left.rClass == right.rClass && left.databaseKey == right.databaseKey && left.category == right.category
    }
    
    

    
}
