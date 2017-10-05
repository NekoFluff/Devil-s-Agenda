//
//  Task.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/13/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import Foundation

class Task_OLD : NSObject, NSCoding {
    let desc : String
    let due : NSDate

    
    init(desc : String, due : NSDate) {
        self.desc = desc
        self.due = due
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        desc = aDecoder.decodeObject(forKey: "description") as! String
        due = aDecoder.decodeObject(forKey: "due") as! NSDate
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(description, forKey: "description")
        aCoder.encode(due, forKey: "due")
    }
}
