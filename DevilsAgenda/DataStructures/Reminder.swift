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
    let text : String
    
    init(date : Date, reminderText: String) {
        self.date = date
        self.text = reminderText
    }
    
    func toDict() -> [String : String] {
        
        //Create date formatter
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy HH:mm:ss"
        
        //Create dictionary to store data in
        var dict = Dictionary<String, String>()
        
        //Add data
        dict[Constants.ReminderFields.text] = self.text
        
        let dateString = df.string(from: date)
        dict[Constants.ReminderFields.date] = dateString

        
        return dict
    }
}
