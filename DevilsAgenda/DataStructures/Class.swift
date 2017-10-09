//
//  Class.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/13/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import Foundation

class Class : Equatable {
    var name : String
    var color : String
    var databaseKey : String?
    
    init(name: String, color: String) {
        self.name = name
        self.color = color
    }
    
    init(data : [String : Any], databaseKey: String) {
        self.name = data[Constants.ClassFields.name] as? String ?? ""
        self.color = data[Constants.ClassFields.color] as? String ?? ""
        self.databaseKey = databaseKey
    }
    
    func toDict() -> [String : String] {
        var data = [Constants.ClassFields.name : name,
                Constants.ClassFields.color : color]
        
        if databaseKey != nil {
            data[Constants.ClassFields.key] = databaseKey
        }
        
        return data
    }
    
    static func ==(left: Class, right: Class) -> Bool {
        return left.name == right.name && left.databaseKey == right.databaseKey && left.color == right.color
    }
}
