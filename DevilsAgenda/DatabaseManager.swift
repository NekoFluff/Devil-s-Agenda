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
    func addedTask();
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
            
            
            if let newTasksData = classData[Constants.ClassFields.tasks] as? Dictionary<String, [String : String]> {
                for (_, taskData) in newTasksData {
                    let newTask = Task(newClass, data: taskData)
                    tasks.append(newTask)
                    taskDelegate?.addedTask()
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
        if let handle = _classRefHandle {
            self.ref.child("users").child(Auth.auth().currentUser!.uid).child("classes").removeObserver(withHandle: handle)
        }
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
        var c = c
        var classPath = self.ref.child("users").child(Auth.auth().currentUser!.uid).child("classes")
        if c.databaseKey == nil {
            classPath = classPath.childByAutoId()
            c.databaseKey = classPath.key
        } else {
            classPath.child(c.databaseKey!)
        }
        
        classPath.setValue(c.toDict())
    }
    
    func saveTask(forClass classKey: String, withData data: [String : String], andTaskKey taskKey: String? = nil) {
        let path = "users/\(Auth.auth().currentUser!.uid)/classes/\(classKey)/\(Constants.ClassFields.tasks)"
        
        if let task = taskKey { //Update a task
            self.ref.updateChildValues([path+"/"+task : data])
        } else { //Create a new task
            self.ref.child(path).childByAutoId().setValue(data)
        }
        self.taskDelegate?.addedTask()
    }

    func refresh() {
        
    }
}
