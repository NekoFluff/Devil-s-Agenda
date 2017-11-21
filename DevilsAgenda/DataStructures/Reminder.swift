//
//  Reminder.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/13/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import Foundation

struct Reminder {
    let date : Date
    let title : String
    let description : String
    
    init(date : Date, title: String, description: String) {
        self.date = date
        self.title = title
        self.description = description
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
