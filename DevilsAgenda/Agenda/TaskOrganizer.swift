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
    func completedTask(_ task: Task, inSection section: taskSection, andIndexPath indexPath: IndexPath?)
    func updatedTask(_ task: Task, inSection section: taskSection)
    func deletedClass(_ class: Class)
    func reloadTasks()
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
    
    
    var organizedTasks : [String : NSPointerArray] = [:]
    var delegate : TaskOrganizerDelegate?
    
    init() {
        sortTasks(database.tasks)
        database.taskDelegate = self
    }
    
    func sortTasks(_ tasks: NSPointerArray) {
        organizedTasks = [:]
        
        for i in 0..<tasks.count {
            if let task = tasks.object(at: i) as? Task {
                let _ = addTask(task)
            }
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
                organizedTasks[section.rawValue]?.addObject(t)
                return organizedTasks[section.rawValue]!.count - 1
                
            }
        } else {
            organizedTasks[section.rawValue] = NSPointerArray(options: NSPointerFunctions.Options.weakMemory)
            organizedTasks[section.rawValue]?.addObject(t)
            
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
            
            if let middleDueDate = (tasks.object(at: M) as! Task).dueDate {
                if dueDate > middleDueDate {
                    L = M + 1
                } else {
                    R = M - 1
                }
            }
        }
        
        organizedTasks[section.rawValue]!.insertObject(t, at: L)
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
    
    func reloadTasks() {
        self.delegate?.reloadTasks()
    }
    func deletedClass(_ c: Class) {
        self.sortTasks(database.tasks)
        delegate?.deletedClass(c)
    }

    func addedTask(_ task: Task) {
        print("ADDING \(task.desc)")
        let (section, index) = addTask(task)
        delegate?.addedTask(task, toSection: section, withIndex: index)
    }
    
    func updatedTask(_ task: Task) {
        print("UPDATING \(task.desc)")
        let section = getTaskSectionForTask(task)
        delegate?.updatedTask(task, inSection: section)
    }
    
    func completedTask(_ task: Task, withIndexPath indexPath: IndexPath?) {
        print("DELETING \(task.desc)")
        let section = getTaskSectionForTask(task)

        if let indexPath = indexPath, organizedTasks[section.rawValue]!.count - 1 >= indexPath.row && organizedTasks[section.rawValue]!.object(at: indexPath.row) === task {
            
            organizedTasks[section.rawValue]!.removeObject(at: indexPath.row)
            print("Used indexPath \(indexPath) to delete task '\(task.desc)' in organized list.")
            
        } else {
            
            //Enumerate through array and attempt to delete it there.
            for i in 0..<organizedTasks[section.rawValue]!.count {
                if organizedTasks[section.rawValue]?.object(at: i) === task {
                    organizedTasks[section.rawValue]!.removeObject(at: i)
                    break
                }
            }
            print("Used enumeration to delete task in organized list.")
        }
        
        delegate?.completedTask(task, inSection: section, andIndexPath: indexPath)
        
    }
    
    func signOut() {
        self.organizedTasks.removeAll();
        print("Removed all organized tasks")
    }
}
