//
//  Class.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/13/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import Foundation

class Class_OLD : NSObject, NSCoding {
    var name : String
    var color : String
    var tasks : [Task_OLD]
    
    init(name: String, color: String, tasks : [Task_OLD]) {
        self.name = name
        self.color = color
        self.tasks = tasks
    }
    
    init(data : [String : String]) {
        self.name = data[Constants.ClassFields.name] ?? ""
        self.color = data[Constants.ClassFields.color] ?? ""
        self.tasks = [Task_OLD]() //data[Constants.ClassFields.tasks]
    }
    
    func toDict() -> [String : String] {
        return [Constants.ClassFields.name : name,
                Constants.ClassFields.color : color]
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.color = aDecoder.decodeObject(forKey: "tasks") as! String
        self.tasks = aDecoder.decodeObject(forKey: "tasks") as! [Task_OLD]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.color, forKey: "color")
        aCoder.encode(self.tasks, forKey: "tasks")
    }
    
    
    
    var filePath : String {
        let manager = FileManager.default
        let url = manager.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
        return url!.appendingPathComponent("Class").path
    }
    
    func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: "file.txt")
    }
}
