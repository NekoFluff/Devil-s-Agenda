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
    
    var rClass : Class
    var category : taskCategory?
    var desc : String = ""
    var dueDate : Date?
    var todoDate : Date?
    var databaseKey : String?
    
    init(_ rClass: Class, category: taskCategory, desc : String, dueDate : Date? = nil, todoDate: Date? = nil) {
        self.rClass = rClass
        reconfigure(rClass, category: category, desc: desc, dueDate: dueDate, todoDate: todoDate)
    }
    
    init(_ rClass: Class, data: [String : String], databaseKey: String) {
        self.rClass = rClass
        
        reconfigure(rClass,
                    category: taskCategory(rawValue: data[Constants.TaskFields.category] ?? "Assignment")!,
                    desc: (data[Constants.TaskFields.description]) ?? "ERROR_DESC")
        
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy HH:mm:ss"
        
        if let date = data[Constants.TaskFields.dueDate] {
            self.dueDate = df.date(from : date)
        }
        
        if let date = data[Constants.TaskFields.todoDate] {
            self.todoDate = df.date(from : date)
        }
        
        self.databaseKey = databaseKey
    }
    
    
    
    func reconfigure(_ rClass: Class, category: taskCategory, desc : String, dueDate : Date? = nil, todoDate: Date? = nil) {
        
        self.rClass = rClass
        self.category = category
        self.desc = desc
        self.dueDate = dueDate
        self.todoDate = todoDate
    }
    
    func toDict() -> [String : String] {
        
        //Create date formatter
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy HH:mm:ss"
        
        //Create dictionary to store data in
        var dict = Dictionary<String, String>()
        
        //Add data
        if let category = category {
            dict[Constants.TaskFields.category] = category.rawValue
        }
        
        dict[Constants.TaskFields.description] = self.desc
        
        if let dueDate = dueDate {
            let dateString = df.string(from: dueDate)
            dict[Constants.TaskFields.dueDate] = dateString
        }
        
        if let todoDate = todoDate {
            let dateString = df.string(from: todoDate)
            dict[Constants.TaskFields.todoDate] = dateString
        }
        
        return dict
    }
    
    deinit {
        print("De-allocating Task \(desc)")
    }
    
    static func ==(left: Task, right: Task) -> Bool {
        return left.rClass == right.rClass && left.databaseKey == right.databaseKey && left.category == right.category
    }
    
}
