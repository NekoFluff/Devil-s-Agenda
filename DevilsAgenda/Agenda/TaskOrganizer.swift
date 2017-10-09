//
//  TaskOrganizer.swift
//  DevilsAgenda
//
//  Created by Alexander Nou on 10/8/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import SwiftDate

protocol TaskOrganizerDelegate {
    func addedTask(_ task: Task, toSection section: taskSection)
}

enum taskSection : String {
    case overdue = "Overdue", tbd = "To be determined", monday = "Monday", tuesday = "Tuesday", wednesday = "Wednesday", thursday = "Thursday", friday = "Friday", saturday = "Saturday", sunday = "Sunday", later = "Later"
}

enum weekdays : Int {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
}

class TaskOrganizer {
    
    static let defaultOrganizer = TaskOrganizer()
    
    let date = Date()
    let database = DatabaseManager.defaultManager
    
    var organizedTasks : [String : [Task]] = [:]
    var delegate : TaskOrganizerDelegate?
    
    init() {
        sortTasks(database.tasks)
        database.taskDelegate = self
    }
    
    func sortTasks(_ tasks: [Task]) {
        for (t) in tasks {
            addTask(t)
        }
    }
    
    func addTask(_ t: Task) -> taskSection {
        if let dueDate = t.dueDate {
            
            //let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            
            //var components = calendar.dateComponents([.month, .day, .year], from: dueDate)
            //components.setValue(0, for: .hour)
            //components.setValue(0, for: .second)
            
            //let oneWeekLater = calendar.date(from: components)!.add(components: [.day : 1])
            
            //----------- Overdue or Past 1 Week
            if dueDate < date {
                addTask(t, toSection: taskSection.overdue)
                return taskSection.overdue
                
            } else if dueDate > date.add(components:[.day : 7]) {
                addTask(t, toSection: taskSection.later)
                return taskSection.later
            }
            
            let section = getTaskSectionForDate(dueDate)
            addTask(t, toSection: section)
            return section
            
        } else { //---------- No due date
            addTask(t, toSection: taskSection.tbd)
            return taskSection.tbd
        }
    }
    
    private func addTask(_ t: Task, toSection section: taskSection) {
        if organizedTasks[section.rawValue] != nil {
            organizedTasks[section.rawValue]!.append(t)
        } else {
            organizedTasks[section.rawValue] = [t]
        }
    }
    
    func countForSection(_ section: taskSection) -> Int {
        return organizedTasks[section.rawValue]?.count ?? 0
    }
    
    func getTaskSectionForDate(_ date: Date) -> taskSection {
        //------------ Mon/Tues/Wed/Thurs/Fri/Sat/Sun
        switch (weekdays(rawValue: date.weekday)!) {
        case .sunday:
            return taskSection.sunday
        case .monday:
            return taskSection.monday
        case .tuesday:
            return taskSection.tuesday
        case .wednesday:
            return taskSection.wednesday
        case .thursday:
            return taskSection.thursday
        case .friday:
            return taskSection.friday
        case .saturday:
            return taskSection.saturday
        }
    }
    
    func weekdayForTaskSection(_ section: taskSection) -> weekdays? {
        switch (section) {
        case .monday:
            return weekdays.monday
        case .tuesday:
            return weekdays.tuesday
        case .wednesday:
            return weekdays.wednesday
        case .thursday:
            return weekdays.thursday
        case .friday:
            return weekdays.friday
        case .saturday:
            return weekdays.saturday
        case .sunday:
            return weekdays.sunday
        default:
            return nil
        }
    }
}

extension TaskOrganizer : DatabaseManagerTaskDelegate {
    func addedTask(_ task: Task) {
        let section = addTask(task)
        delegate?.addedTask(task, toSection: section)
    }
    
    func updatedTask(_ task: Task) {
        print("updated task. task organizer requires function implementation")
    }
}
