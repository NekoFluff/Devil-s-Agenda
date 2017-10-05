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

struct Task {
    
    let rClass : Class
    var category : taskCategory?
    var desc : String
    var dueDate : Date?
    var todoDate : Date?
    
    init(_ rClass: Class, category: taskCategory, desc : String, dueDate : Date? = nil, todoDate: Date? = nil) {
        self.rClass = rClass
        self.category = category
        self.desc = desc
        self.dueDate = dueDate
        self.todoDate = todoDate
    }
    
    init(_ rClass: Class, data: [String : String]) {
        self.rClass = rClass
        
        self.category = taskCategory(rawValue: data[Constants.TaskFields.category] ?? "Assignment")
        self.desc = (data[Constants.TaskFields.description]) ?? "ERROR_DESC"
        
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy HH:mm:ss"
        
        if let date = data[Constants.TaskFields.dueDate] {
            self.dueDate = df.date(from : date)
        }
        
        if let date = data[Constants.TaskFields.todoDate] {
            self.todoDate = df.date(from : date)
        }
        
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
    
    
}
