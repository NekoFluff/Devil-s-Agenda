//
//  DatabaseManager.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/15/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import Foundation
import Firebase

protocol DatabaseManagerClassDelegate {
    func addedClass(class: Class);
}

protocol DatabaseManagerTaskDelegate {
    func addedTask(_ task: Task);
    func updatedTask(_ task: Task);
    func deletedTask(_ task: Task, withIndexPath indexPath: IndexPath?);
}

class DatabaseManager {
    
    static let defaultManager = DatabaseManager()
    var classDelegate : DatabaseManagerClassDelegate?
    var taskDelegate : DatabaseManagerTaskDelegate?
    
    var classes = [Class]()
    var tasks = [Task]()
    
    private var ref : DatabaseReference!
    private var _classRefHandle : DatabaseHandle?
    //private var _taskRefHandle : DatabaseHandle? //TODO: REMOVE?
    
    private init() {
        configureDatabase()
    }
    
    private func configureDatabase() {
        print("Configuring database..")
        self.ref = Database.database().reference()
        
        guard Auth.auth().currentUser != nil else { return }
//        //Retrieve all class values once at the beginning
//        self.ref.child("users").child(Auth.auth().currentUser!.uid).child("classes").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
//            print("Adding all available classes")
//            
//            self.createClasses(fromSnapshot: snapshot)
//        })
        addClassListener()

        print("Configured database!")
    }
    
//    private func createClasses(fromSnapshot snapshot: DataSnapshot) {
//        print(snapshot.value)
//        if let classesData = snapshot.value as? Dictionary<String, [String : String]> {
//            for (key, aClass) in classesData {
//                let newClass = Class(data: aClass, databaseKey: key)
//                self.classes.append(newClass)
//                print("Added Class '\(newClass.name) to global 'classes'")
//            }
//        }
//    }
    
    private func createClass(fromSnapshot snapshot: DataSnapshot) -> Class? {
        if let classData = snapshot.value as? Dictionary<String, Any> {
            let newClass = Class(data: classData, databaseKey: snapshot.key)
            self.classes.append(newClass)
            print("Added Class '\(newClass.name)' to global 'classes'")
            
            //Tasks
            if let newTasksData = classData[Constants.ClassFields.tasks] as? Dictionary<String, [String : String]> {
                for (taskKey, taskData) in newTasksData {
                    let newTask = Task(newClass, data: taskData, databaseKey: taskKey)
                    tasks.append(newTask)
                    taskDelegate?.addedTask(newTask)
                }
            }
            return newClass
        }
        return nil
    }
    
    
    
    func addClassListener() {
        guard _classRefHandle == nil else {return}
            
        //Listen for new class additions in the Firebase database
        _classRefHandle = self.ref.child("users").child(Auth.auth().currentUser!.uid).child("classes").observe(DataEventType.childAdded, with: { [weak self](snapshot) in
            guard let strongSelf = self else { return }
            
            print("Adding new class")
            if let newClass = strongSelf.createClass(fromSnapshot: snapshot) {
                strongSelf.classDelegate?.addedClass(class: newClass)
            }
        })
    }
    
    func removeClassListener() {
        if let handle = _classRefHandle, let uid = Auth.auth().currentUser?.uid {
            self.ref.child("users").child(uid).child("classes").removeObserver(withHandle: handle)
        }
    }
    
    func removeAllListeners() {
        self.ref.removeAllObservers()
    }
    /*
    func addTaskListener() {
        guard _taskRefHandle == nil else {return}
        
        //Listen for new class additions in the Firebase database
        _taskRefHandle = self.ref.child("users").child(Auth.auth().currentUser!.uid).child("classes").observe(DataEventType.childAdded, with: { [weak self](snapshot) in
            guard let strongSelf = self else { return }
            
            strongSelf.createClass(fromSnapshot: snapshot)
            
        })
    }
    
    func removeTaskListener() {
        if let handle = _taskRefHandle {
            self.ref.child("classes").removeObserver(withHandle: handle)
        }
    }*/
    
    func saveClass( _ c: Class) {

        var classPath = self.ref.child("users").child(Auth.auth().currentUser!.uid).child("classes")
        if c.databaseKey == nil {
            classPath = classPath.childByAutoId()
            c.databaseKey = classPath.key
        } else {
            classPath.child(c.databaseKey!)
        }
        
        classPath.setValue(c.toDict())
    }
    
    func saveTask( _ t: inout Task) {

        if let path = getTasksPath(t.rClass) {
            let data = t.toDict()
            
            if let taskKey = t.databaseKey { //Update a task
                self.ref.updateChildValues([path+"/"+taskKey : data])
                
                self.taskDelegate?.updatedTask(t)
                
            } else { //Create a new task
                let taskPath = self.ref.child(path).childByAutoId()
                let taskKey = taskPath.key
                
                taskPath.setValue(data)
                t.databaseKey = taskKey
                self.tasks.append(t)
                
                self.taskDelegate?.addedTask(t)
            }
        }
        
    }
    
    func deleteTask(_ t: Task, atIndexPath indexPath: IndexPath) {

        if let path = getPathForTask(t) {

            self.ref.child(path).removeValue()
            
                
            for (i,task) in tasks.enumerated() {
                if task === t {
                    tasks.remove(at: i)
                    self.taskDelegate?.deletedTask(task, withIndexPath: indexPath);
                }
            }
        }
    }
    
    func completeTask(_ t: Task) {
        
    }
    
    private func getTasksPath(_ c: Class) -> String? {
        if let classKey = c.databaseKey {
            
            return "users/\(Auth.auth().currentUser!.uid)/classes/\(classKey)/\(Constants.ClassFields.tasks)"
        } else {
            print("ERROR: saveTask(_ t: Task) FAILED. Class key missing!")
            return nil
        }
    }
    
    private func getPathForTask(_ t: Task) -> String? {
        if let tasksPath = getTasksPath(t.rClass) {
            if let taskKey = t.databaseKey {
                return tasksPath + "/" + taskKey
            } else {
                print("ERROR: No corresponding task in Firebase Database for \(t.desc)")
            }
        }
        
        return nil
    }

    func refresh() {
        
    }
}
