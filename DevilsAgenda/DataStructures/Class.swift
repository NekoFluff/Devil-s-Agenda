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
    var daysOfTheWeek : [Bool]?
    
    //MARK: - Initializers
    init(name: String, color: String, owner: String, professor: String?, location: String?, startTime : Date?, endTime : Date?, daysOfTheWeek : [Bool]?, shared: Bool? = false) {
        self.name = name
        self.color = color
        self.owner = owner
        self.professor = professor
        self.location = location
        self.startTime = startTime
        self.endTime = endTime
        self.daysOfTheWeek = daysOfTheWeek
        self.isShared = shared!
    }
    
    init(data : [String : Any], databaseKey: String) {
        self.name = data[Constants.ClassFields.name] as? String ?? ""
        self.color = data[Constants.ClassFields.color] as? String ?? ""
        self.owner = data[Constants.ClassFields.owner] as? String ?? ""
        self.isShared = data[Constants.ClassFields.shared] as? Bool ?? false
        self.professor = data[Constants.ClassFields.professor] as? String
        self.location = data[Constants.ClassFields.location] as? String
        self.daysOfTheWeek = data[Constants.ClassFields.daysOfTheWeek] as? [Bool]
        
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        
        if let start = data[Constants.ClassFields.startTime] as? String {
            self.startTime = df.date(from : start)
        }
        
        if let end = data[Constants.ClassFields.endTime] as? String {
            self.endTime = df.date(from : end)
        }
        
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
        

        
        if let professor = self.professor {
            data[Constants.ClassFields.professor] = professor
        }
        
        if let location = self.location {
            data[Constants.ClassFields.location] = location
        }
        
        if let startTime = self.startTime {
            data[Constants.ClassFields.startTime] = convertTimeToString(startTime)
        }
        
        if let endTime = self.endTime {
            data[Constants.ClassFields.endTime] = convertTimeToString(endTime)
        }
        
        if let daysOfTheWeek = self.daysOfTheWeek {
            data[Constants.ClassFields.daysOfTheWeek] = daysOfTheWeek
        }
        
        if databaseKey != nil {
            data[Constants.ClassFields.key] = databaseKey
        }
        
        
        return data
    }
    
    static func ==(left: Class, right: Class) -> Bool {
        return left.name == right.name && left.databaseKey == right.databaseKey && left.color == right.color
    }
    
    func convertTimeToString(_ time: Date, format: String? = "HH:mm:ss") -> String {
        let df = DateFormatter()
        df.dateFormat = format!
        
        return df.string(from: time)
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
    
    func minFromMidnight(date : Date) -> Int {
        let hour = date.hour
        let min = date.minute
        
        return hour * 60 + min
    }
    
    func minSinceHour(date: Date?, comparedToHour hour: Int) -> Int {
        //assume compare date is the current hour.
        if let date = date {
            let targetHour = date.hour
            let targetMin = date.minute
            
            var result = (targetHour-hour) * 60 + targetMin
            if result < 0 {
                result = (24*60) + result //total minutes in day (24*60) + negative time
            }
            return result
        } else {
            return 0;
        }
    }
}
