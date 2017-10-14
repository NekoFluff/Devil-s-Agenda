//
//  TaskOrganizer.swift
//  DevilsAgenda
//
//  Created by Alexander Nou on 10/8/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import SwiftDate

protocol TaskOrganizerDelegate {
    func addedTask(_ task: Task, toSection section: taskSection, withIndex index: Int)
    //func deletedTask(_ task: Task, inSection section: taskSection)
    func updatedTask(_ task: Task, inSection section: taskSection)
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
        addAndSortTasks(database.tasks)
        database.taskDelegate = self
    }
    
    private func addAndSortTasks(_ tasks: [Task]) {
        for (t) in tasks {
            addTask(t)
        }
    }
    
    func addTask(_ t: Task) -> (section: taskSection, index: Int) {
        let section = getTaskSectionForTask(t)
        
        return (section, addTask(t, toSection: section))
    }
    
    private func addTask(_ t: Task, toSection section: taskSection) -> Int{
        if organizedTasks[section.rawValue] != nil {
            
            
            if t.dueDate != nil {
                
                return binarySearchInsert(t, intoSection: section)
                
            } else {
                organizedTasks[section.rawValue]?.append(t)
                return organizedTasks[section.rawValue]!.count - 1
                
            }
        } else {
            organizedTasks[section.rawValue] = [t]
            return 0
        }
    }
    
    private func binarySearchInsert(_ t: Task, intoSection section: taskSection) -> Int {
        guard let dueDate = t.dueDate else {return -1}
        
        let tasks = organizedTasks[section.rawValue]!
        
        var L = 0;
        var R = organizedTasks[section.rawValue]!.count - 1
    
        while (L <= R) {
            let M = (L+R)/2
            
            if let middleDueDate = tasks[M].dueDate {
                if dueDate > middleDueDate {
                    L = M + 1
                } else {
                    R = M - 1
                }
            }
        }
        
        organizedTasks[section.rawValue]!.insert(t, at: L)
        return L
    }
    
    func getTaskSectionForTask(_ t: Task) -> taskSection {
        if let dueDate = t.dueDate {
            
            let calendar = Calendar.current
            
            var components = calendar.dateComponents([.month, .day, .year, .hour, .second], from: date)
            components.setValue(0, for: .hour)
            components.setValue(0, for: .second)
            
            let oneWeekLater = calendar.date(from: components)!.add(components: [.day : 7])
            
            //----------- Overdue or Past 1 Week
            if dueDate < date {
                return taskSection.overdue
                
            } else if dueDate > oneWeekLater {
                return taskSection.later
            }
            
            let section = getTaskSectionForDate(dueDate)
            return section
            
        } else { //---------- No due date
            
            return taskSection.tbd
        }
    }
    
    func countForSection(_ section: taskSection) -> Int {
        return organizedTasks[section.rawValue]?.count ?? 0
    }
    
    /**
     A function that returns the taskSection (Mon-Sun) for a specific date
     - parameters:
     - date: The date
     
     - returns:
     taskSection for the specified date
     
     */
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
        let (section, index) = addTask(task)
        delegate?.addedTask(task, toSection: section, withIndex: index)
    }
    
    func updatedTask(_ task: Task) {
        print("updated task. task organizer requires function implementation")
        let section = getTaskSectionForTask(task)
        
        delegate?.updatedTask(task, inSection: section)
        print("Used enumeration to delete task in organized list.")
    }
    
    func deletedTask(_ task: Task, withIndexPath indexPath: IndexPath?) {
        let section = getTaskSectionForTask(task).rawValue
        
        if let indexPath = indexPath, organizedTasks[section]!.count - 1 >= indexPath.row && organizedTasks[section]![indexPath.row] === task {
            
            organizedTasks[section]!.remove(at: indexPath.row)
            print("Used indexPath to delete task in organized list.")
            
        } else {
            
            //Enumerate through array and attempt to delete it there.
            for (i,t) in organizedTasks[section]!.enumerated() {
                if t === task {
                    organizedTasks[section]!.remove(at: i)
                    break
                }
            }
            print("Used enumeration to delete task in organized list.")
        }
        
    }
    
}
