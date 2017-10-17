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
    func deletedClass(_ c: Class);
    func addedSharedClass(code: String, newClass: Class?, customErrorMessage msg: String?);
}

protocol DatabaseManagerTaskDelegate {
    func addedTask(_ task: Task);
    func updatedTask(_ task: Task);
    func deletedTask(_ task: Task, withIndexPath indexPath: IndexPath?);
    func deletedClass(_ c: Class);
}

class DatabaseManager {
    
    static let defaultManager = DatabaseManager()
    var classDelegate : DatabaseManagerClassDelegate?
    var taskDelegate : DatabaseManagerTaskDelegate?
    
    var classes = [Class]()
    var tasks = [Task]()
    var followedClasses = Dictionary<String, Dictionary<String, Bool>>()
    
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
        downloadFollowedClasses()
        
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
    
    private func createClass(fromSnapshot snapshot: DataSnapshot) -> (class :Class, tasks: [Task])? {
        if let classData = snapshot.value as? Dictionary<String, Any> {
            let newClass = Class(data: classData, databaseKey: snapshot.key)
            self.classes.append(newClass)
            print("Added Class '\(newClass.name)' to global 'classes'")
            
            //Tasks
            var newTasks = [Task]()
            if let newTasksData = classData[Constants.ClassFields.tasks] as? Dictionary<String, [String : String]> {
                for (taskKey, taskData) in newTasksData {
                    
                    //Only create a new task if it hasn't already been completed
                    if (newClass.isShared) {
                        if let classCompletionInfo = followedClasses[snapshot.key], let isCompleted = classCompletionInfo[taskKey] {
                            
                            if isCompleted {continue}
                        }
                    }
                    
                    let newTask = Task(newClass, data: taskData, databaseKey: taskKey)
                    tasks.append(newTask)
                    newTasks.append(newTask)
                    taskDelegate?.addedTask(newTask)
                }
            }
            return (newClass, newTasks)
        }
        return nil
    }
    
    func downloadFollowedClasses() {
        let followedClassesPath = getFollowedClassesPath()
        
        //Get all the followedClasses
        self.ref.child(followedClassesPath).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            print("Downloading shared classes")
            
            //Unwrap the data
            if let followedClassesData = snapshot.value as? Dictionary<String, Any> {
                let sharedClassesPath = self.getSharedClassesPath()
                
                //For each of the followed classes download the class data
                for (classKey, _) in followedClassesData {
                    
                    //Add the tasks for the followed class
                    if let classData = followedClassesData[classKey] as? Dictionary<String, Any> {
                        
                        self.followedClasses[classKey] = classData["tasks"] as? Dictionary<String, Bool> ?? nil
                        
                        print("Tasks: \(String(describing: classData["tasks"] as? Dictionary<String, Bool>))")
                        
                    }
                    
                    //Download the class information from the shared location
                    self.ref.child(sharedClassesPath+"/"+classKey).observeSingleEvent(of: DataEventType.value, with: { (snapshot2) in
                        
                        //Create a class for every followed class
                        if let (newClass, _) = self.createClass(fromSnapshot: snapshot2) {
                            self.classDelegate?.addedClass(class: newClass)
                        }
                    })
                }
            }
            
            print("Finished downloading shared classes")
        })
        
        //
        //                                self.tasks = self.tasks.filter({ (task) -> Bool in
        //                                    if task.rClass.isShared, let followedClassesData = self.followedClasses[task.rClass.databaseKey!], let isCompleted = followedClassesData[task.databaseKey!] {
        //                                        self.taskDelegate?.deletedTask(task, withIndexPath: nil)
        //                                        return !isCompleted
        //                                    }
        //
        //                                    return true
        //
        //                                })
    }
    
    func addClassListener() {
        guard _classRefHandle == nil else {return}
            
        //Listen for new class additions in the Firebase database
        _classRefHandle = self.ref.child("users").child(Auth.auth().currentUser!.uid).child("classes").observe(DataEventType.childAdded, with: { [weak self](snapshot) in
            guard let strongSelf = self else { return }
            
            print("Adding new class")
            if let (newClass, _) = strongSelf.createClass(fromSnapshot: snapshot) {
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
    
    //MARK: CLASS Methods
    func saveClass(_ c: Class) {
        guard !c.isShared else {saveSharedClass(c); return}
        
        var classPath = self.ref.child("users").child(Auth.auth().currentUser!.uid).child("classes")
        
        if c.databaseKey == nil {
            classPath = classPath.childByAutoId()
            c.databaseKey = classPath.key
        } else {
            classPath.child(c.databaseKey!)
        }
        
        classPath.setValue(c.toDict())
    }
    
    func deleteClass(atIndex index: Int) {
        guard !classes[index].isShared else {deleteSharedClass(atIndex: index); return}
        
        if let path = getClassPath(classes[index]) {
            //Delete the class in the database
            self.ref.child(path).removeValue()

            //Delete all tasks associated with that task
            tasks = tasks.filter({ (task) -> Bool in
                task.rClass != classes[index]
            })
            
            //Delete the class
            let deletedClass = classes.remove(at: index)
            
            //Send signals
            self.taskDelegate?.deletedClass(deletedClass)
            self.classDelegate?.deletedClass(deletedClass)
        }
    }
    
    //MARK: SHARED CLASS Methods
    func saveSharedClass(_ c: Class) {
        guard c.isShared else {saveClass(c); return}
        
        let sharedClassesPath = getSharedClassesPath()
        let data = c.toDict()
        
        if let classKey = c.databaseKey { //Overwrite old class
            self.ref.updateChildValues([sharedClassesPath+"/"+classKey : data, getClassPath(c)! : []])
            
            print("Saved old class \(classKey)")
            
        } else { //Create new class
            let newClassPath = self.ref.child(sharedClassesPath).childByAutoId()
            let classKey = newClassPath.key
            
            newClassPath.setValue(data)
            c.databaseKey = classKey
            
            print("Saved new class \(classKey)")
            
            addSharedClass(key: classKey)
        }
    }
    
    func deleteSharedClass(atIndex index: Int) {
        let c = classes[index]
        guard c.isShared else {deleteClass(atIndex: index); return}
        
        let followedClassesPath = getFollowedClassesPath()
        
        if let classKey = c.databaseKey {
            //Delete the class in the database
            self.ref.child(followedClassesPath+"/\(classKey)").removeValue()
            
            //Delete all tasks associated with that task
            tasks = tasks.filter({ (task) -> Bool in
                task.rClass != c
            })
            
            //Delete the class
            let deletedClass = classes.remove(at: index)
            
            //Delete the class from the followedClasses
            followedClasses[classKey] = nil
            
            //Send signals
            self.taskDelegate?.deletedClass(deletedClass)
            self.classDelegate?.deletedClass(deletedClass)
        }
        
    }
    
    //Called when adding a shared class
    func addSharedClass(key: String) {
        let sharedClassesPath = getSharedClassesPath()
        
        guard followedClasses[key] == nil else {self.classDelegate?.addedSharedClass(code: key, newClass: nil, customErrorMessage: "You've already downloaded this class: \(key)"); return}
        
        self.ref.child(sharedClassesPath+"/"+key).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            print("Adding shared class \(key)")
            
            if let (newClass, newTasks) = self.createClass(fromSnapshot: snapshot), let classKey = newClass.databaseKey {
            
                //Construct data structure to add to database
                var followedClass = Dictionary<String, Any>()
                followedClass[Constants.FollowedClassFields.owner] = newClass.owner
                let completion = self.constructCompletionDictionary(tasks: newTasks)
                followedClass[Constants.FollowedClassFields.tasks] = completion
                
                //Update the database
                self.ref.child(self.getFollowedClassesPath()+"/"+classKey).setValue(followedClass)
                
                //Update local followedClasses structure
                self.followedClasses[key] = completion
                
                //Send signals to update
                print("Added shared class \(classKey)")
                self.classDelegate?.addedClass(class: newClass)
                self.classDelegate?.addedSharedClass(code: key, newClass: newClass, customErrorMessage: nil)
            } else {
                
                //Send failure signal
                print("Failed to add shared class \(key)")
                self.classDelegate?.addedSharedClass(code: key, newClass: nil, customErrorMessage: "Failed to find class with key code: \(key)")
            }
        })
        
    }
    
    func constructCompletionDictionary(tasks: [Task]) -> Dictionary<String, Bool> {
        var completionDictionary = Dictionary<String, Bool>()
        
        for task in tasks {
            if let key = task.databaseKey {
                completionDictionary[key] = false
            }
        }
        
        return completionDictionary
    }
    
    //MARK: TASK Methods
    func saveTask( _ t: inout Task) {
        
        //Determine save path
        var path : String?
        if t.rClass.isShared {
            path = getSharedClassesPath()+"/\(t.rClass.databaseKey!)/\(Constants.ClassFields.tasks)/"
        } else {
            path = getTasksPath(t.rClass)
        }
        
        if let path = path {
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
    
    //TODO: Filter tasks if they have been completed...
    func deleteTask(_ t: Task, atIndexPath indexPath: IndexPath) {
        
        var deletedTask = false
        
        if t.rClass.isShared, let classKey = t.rClass.databaseKey, let taskKey = t.databaseKey {
            
            let followedClassesPath = getFollowedClassesPath()
            self.ref.child(followedClassesPath+"/\(classKey)/\(Constants.FollowedClassFields.tasks)/"+taskKey).setValue(true)
            
            deletedTask = true
            
        } else { //Task is not shared
            
            if let path = getPathForTask(t) {
                //Delete the task from the database
                self.ref.child(path).removeValue()
                deletedTask = true
            }
        }
        
        if deletedTask {
            //Delete the task from the tasks array
            for (i,task) in tasks.enumerated() {
                if task === t {
                    tasks.remove(at: i)
                    
                    //Send the signal to delete the task in the TaskOrganizer
                    self.taskDelegate?.deletedTask(task, withIndexPath: indexPath);
                    break
                }
            }
        }
    }
    
    func completeTask(_ t: Task) {
        
    }
    
    //MARK: Get Paths
    private func getClassPath(_ c: Class) -> String? {
        if let classKey = c.databaseKey {
            
            return "users/\(Auth.auth().currentUser!.uid)/classes/\(classKey)"
        } else {
            print("ERROR: getClassPath(_ c: Class) FAILED. Class key missing!")
            return nil
        }
    }
    
    private func getTasksPath(_ c: Class) -> String? {
        if let classPath = getClassPath(c) {
            
            return classPath+"/\(Constants.ClassFields.tasks)"
        } else {
            print("ERROR: getTasksPath(_ c: Class) FAILED. Class key missing!")
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
    
    private func getSharedClassesPath() -> String {
        return "shared_classes/"
    }
    
    private func getFollowedClassesPath() -> String {
        return "users/\(Auth.auth().currentUser!.uid)/followed_classes"
    }

    func refresh() {
        
    }
}
