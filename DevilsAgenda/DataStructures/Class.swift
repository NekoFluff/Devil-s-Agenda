//
//  Class.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/13/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import Foundation

class Class : Equatable {
    //MARK: - Main Variables
    var name : String
    var color : String
    var databaseKey : String?
    var isShared : Bool = false
    var owner : String
    var tasks = Dictionary<String, [Task]>()
    
    //MARK: - Optional Variables
    var professor : String?
    var location : String?
    var startTime : Date?
    var endTime : Date?
    
    //MARK: - Initializers
    init(name: String, color: String, owner: String, shared: Bool? = false) {
        self.name = name
        self.color = color
        self.isShared = shared!
        self.owner = owner
    }
    
    init(data : [String : Any], databaseKey: String) {
        self.name = data[Constants.ClassFields.name] as? String ?? ""
        self.color = data[Constants.ClassFields.color] as? String ?? ""
        self.owner = data[Constants.ClassFields.owner] as? String ?? ""
        self.isShared = data[Constants.ClassFields.shared] as? Bool ?? false
        self.databaseKey = databaseKey
    }
    
    deinit {
        print("De-allocating Class \(name)")
    }
    
    //MARK: - Public functions
    func toDict() -> [String : Any] {
        var data = [Constants.ClassFields.name : name,
                    Constants.ClassFields.color : color,
                    Constants.ClassFields.owner : owner,
                    Constants.ClassFields.shared : isShared] as [String : Any]
        
        if databaseKey != nil {
            data[Constants.ClassFields.key] = databaseKey
        }
        
        return data
    }
    
    static func ==(left: Class, right: Class) -> Bool {
        return left.name == right.name && left.databaseKey == right.databaseKey && left.color == right.color
    }
    
    func addTask(_ t : Task, forKey k: String) {
        if self.tasks[t.desc] != nil {
            print("Added Task \(t.desc) to existing list.")
            self.tasks[t.desc]!.append(t);
        } else {
            print("Added Task \(t.desc) to new list.")
            self.tasks[t.desc] = [t]
        }
    }
    
    func removeTask(_ t: Task) {
        if let taskArray = self.tasks[t.desc] {
            for (i, task) in taskArray.enumerated() {
                if task == t {
                    self.tasks[t.desc]!.remove(at: i)
                }
            }
        }
    }
}
