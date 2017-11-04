//
//  DatabaseManager.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/15/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import Foundation
import Firebase
import UserNotifications

protocol DatabaseManagerClassDelegate {
    func addedClass(class: Class);
    func deletedClass(_ c: Class, atIndex index: Int);
    func addedSharedClass(code: String, newClass: Class?, customErrorMessage msg: String?);
    func reloadClass(index: Int);
    func signOut();
}

protocol DatabaseManagerTaskDelegate {
    func addedTask(_ task: Task);
    //func updatedTask(_ task: Task);
    func completedTask(_ task: Task, withIndexPath indexPath: IndexPath?);
    func deletedClass(_ c: Class);
    func reloadTasks();
    func signOut();
}

protocol DatabaseManagerAddClassDelegate {
    func classCodeExists(_ classCode : String, exists: Bool);
}

// Swift 3:
class AtomicCounter {
    private var queue = DispatchQueue(label: "databaseManagerQueue");
    private (set) var value: Int = 0
    
    func increment() {
        queue.sync {
            value += 1
        }
    }
}

class DatabaseManager {
    
    static let defaultManager = DatabaseManager()
    private var DatabaseManagerQueue = DispatchQueue(label: "databaseManagerQueue");
    var classDelegate : DatabaseManagerClassDelegate?
    var taskDelegate : DatabaseManagerTaskDelegate?
    var addClassDelegate : DatabaseManagerAddClassDelegate?
    
    var classes = [Class]()
    var tasks = [Task]()
    var followedClasses = Dictionary<String, Dictionary<String, Bool>>()
    
    var snoozeLengthSec = 600 //SETTING USER CAN CHANGE BASED ON HOW LONG THEY WANT THEIR NOTIFICATION TO SNOOZE FOR (default: 10 min)
    
    private var ref : DatabaseReference!
    private var _classRefHandle : DatabaseHandle?
    //private var _taskRefHandle : DatabaseHandle? //TODO: REMOVE?
    
    private init() {
        
    }
    
    func signIn() {
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
                    newClass.addTask(newTask, forKey: newTask.desc);
                    
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
                        self.DatabaseManagerQueue.sync {
                            if let (newClass, _) = self.createClass(fromSnapshot: snapshot2) {
                                self.classDelegate?.addedClass(class: newClass)
                            }
                        }
                    })
                }
            }
            
            print("Finished downloading shared classes")
        })
        
        //
        //                                self.tasks = self.tasks.filter({ (task) -> Bool in
        //                                    if task.rClass.isShared, let followedClassesData = self.followedClasses[task.rClass.databaseKey!], let isCompleted = followedClassesData[task.databaseKey!] {
        //                                        self.taskDelegate?.completedTask(task, withIndexPath: nil)
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
        _classRefHandle = nil;
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
    
    func deleteClass(_ c : Class, atIndex index: Int) {
        var targetIndex : Int?
        
        //Ensure that the target index is in range and the classes match
        if index < classes.count && c == classes[index] {
            targetIndex = index
        } else {
            //If the index and class do not match, search the classes array
            for (i, _c) in classes.enumerated() {
                if c == _c {
                    targetIndex = i;
                }
            }
        }
        
        if let i = targetIndex {
            guard !classes[i].isShared else {deleteSharedClass(atIndex: i); return}
            
            if let path = getClassPath(classes[i]) {
                //Delete the class in the database
                self.ref.child(path).removeValue()
                
                //Delete all tasks associated with that task
                tasks = tasks.filter({ (task) -> Bool in
                    task.rClass != classes[i]
                })
                
                //Delete the class
                let deletedClass = classes.remove(at: i)
                
                //Send signals
                self.taskDelegate?.deletedClass(deletedClass)
                self.classDelegate?.deletedClass(deletedClass, atIndex: i)
            }
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
            
            addSharedClass(key: classKey)
            
        } else { //Create new class
            let newClassPath = self.ref.child(sharedClassesPath).childByAutoId()
            let classKey = newClassPath.key
            
            newClassPath.setValue(data)
            c.databaseKey = classKey
            
            print("Saved new class \(classKey)")
            
            addSharedClass(key: classKey)
        }
    }
    
    private func deleteSharedClass(atIndex index: Int) {
        let c = classes[index]
        guard c.isShared else {deleteClass(c, atIndex: index); return}
        
        if let classKey = c.databaseKey {
            
            if (c.owner == Auth.auth().currentUser!.uid) {
                
                
                //Delete the class in the database
                let sharedClassesPath = getSharedClassesPath();
                self.ref.child(sharedClassesPath+"/"+classKey).removeValue()
            }
            
            //Remove from follow list
            let followedClassesPath = getFollowedClassesPath()
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
            self.classDelegate?.deletedClass(deletedClass, atIndex: index)
        }
        
    }
    
    //Called when adding a shared class (Class Code)
    func addSharedClass(key: String) {
        let sharedClassesPath = getSharedClassesPath()
        
        guard followedClasses[key] == nil else {self.classDelegate?.addedSharedClass(code: key, newClass: nil, customErrorMessage: "You've already downloaded this class: \(key)"); return}
        
        self.ref.child(sharedClassesPath+"/"+key).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            print("Adding shared class \(key)")
            
            if let (newClass, newTasks) = self.createClass(fromSnapshot: snapshot), let classKey = newClass.databaseKey {
            
                let followedClass = self.constructFollowedClass(newClass, newTasks: newTasks)
                
                //Update the database
                self.ref.child(self.getFollowedClassesPath()+"/"+classKey).setValue(followedClass)
                
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
    

    
//    func removeSharedClass(key: String) {
//        let sharedClassesPath = getSharedClassesPath()
//        
//        guard followedClasses[key] != nil else {return}
//        
//        self.ref.child(sharedClassesPath+"/"+key).removeValue()
//    }
    
    func updateClass( _ c: inout Class, atIndex index : Int, toClass c2: Class) {
        
        //TODO: Get the data from the stabase using an observe single instance method call. (Use information from old class (c)
        //TODO: Update the data with information from the new class (c2)
        //TODO: Delete the old data in the database and replace it with the updated data
        //TODO: Under the circumstance that the 'isShared' value did not change, do not delete the old data. (Simply update it with the updated data)
        guard let classCode = c.databaseKey else {return};
        let sharedClassesPath = getSharedClassesPath()
        
        //Figure out old location
        var oldLocation : String!
        if c.isShared {
            oldLocation = sharedClassesPath+"/\(classCode)"
        } else {
            oldLocation = getClassPath(c)
        }
        
        //Figure out new location
        var newLocation : String!
        if c2.isShared {
            newLocation = sharedClassesPath+"/\(c2.databaseKey!)"
        } else {
            newLocation = getClassPath(c2)
        }
        

        //Update old location data
        self.ref.child(oldLocation).observeSingleEvent(of: DataEventType.value, with: { [c](snapshot) in
            if var data = snapshot.value as? Dictionary<String, Any?> {
                data["name"] = c2.name;
                data["color"] = c2.color;
                data["key"] = c2.databaseKey;
                data["shared"] = c2.isShared;
                
                
                if (!(c.isShared == c2.isShared && c.databaseKey == c2.databaseKey)) {
                    self.ref.updateChildValues([oldLocation : []])
                }
                self.ref.updateChildValues([newLocation : data])
                

                
                let followedClassesPath = self.getFollowedClassesPath()
                if c.isShared && c2.isShared {
                    //Update the database
                    //TODO: Move followed class data...
                    //TODO: Get followed class data from database
                    //TODO: Even if you're not the owner, you should still be able to edit the class code field to move the your existing data.
                    
                    print("Shared -> Shared. Moving old data to new location")
                    
                    //Get data in old location
                    self.ref.child(followedClassesPath+"/"+classCode).observeSingleEvent(of: DataEventType.value, with: { (snapshot2) in
                        
                        if let oldData = snapshot2.value as? Dictionary<String, Any?> {
                            //Move the data
                            self.ref.updateChildValues([followedClassesPath+"/"+c2.databaseKey! : oldData, followedClassesPath+"/"+classCode : []])
                        }
                    })
                    
                    //Update followed classes
                    let temp = self.followedClasses[classCode]
                    self.followedClasses[classCode] = nil
                    self.followedClasses[c2.databaseKey!] = temp
                    
                } else if (!c.isShared && c2.isShared) {
                    print("Non-shared -> Shared. Creating new followed class in database")
                    
                    //Construct data to use in constructFollowedClass() Method
                    let followedClassesPath = self.getFollowedClassesPath()
                    var newTasks : [Task] = []
                    
                    for (_, array) in c.tasks {
                        for i in 0..<array.count {
                            newTasks.append(array.object(at: i) as! Task)
                        }
                    }
                    
                    //Construct followed class
                    let followedClass = self.constructFollowedClass(c, newTasks: newTasks)
                    
                    //Add the class to the database
                    self.ref.updateChildValues([followedClassesPath+"/"+c2.databaseKey! : followedClass])

                } else if (c.isShared && !c2.isShared) {
                    print("Shared -> Non-Shared. Deleting old followed class")
                    //Dete followed class from database
                    self.ref.child(followedClassesPath+"/"+classCode).removeValue()
                    
                    //Delete followed class
                    self.followedClasses[classCode] = nil
                    
                } else {
                    print("Non-shared -> Non-shared. No followed class update necessary")
                }
                
                self.DatabaseManagerQueue.sync {
                    self.classDelegate?.reloadClass(index: index);
                }
                
                self.DatabaseManagerQueue.sync {
                    self.taskDelegate?.reloadTasks();
                }
            }
        })
        
        c.name = c2.name;
        c.databaseKey = c2.databaseKey;
        c.color = c2.color;
        c.isShared = c2.isShared;
    }
    
    func checkIfSharedClassExists(classCode: String) {
        let sharedClassesPath = getSharedClassesPath()
        self.ref.child(sharedClassesPath+"/\(classCode)").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            self.addClassDelegate?.classCodeExists(classCode, exists: snapshot.exists());
            
        })
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
                
                //self.taskDelegate?.updatedTask(t)
                self.taskDelegate?.addedTask(t)
                
            } else { //Create a new task
                let taskPath = self.ref.child(path).childByAutoId()
                let taskKey = taskPath.key
                
                taskPath.setValue(data)
                t.databaseKey = taskKey
                self.tasks.append(t)
                t.rClass.addTask(t, forKey: t.desc);
                
                self.taskDelegate?.addedTask(t)
            }
        }
        
    }
    
    func deleteTask(_ t: Task, atIndexPath indexPath: IndexPath?) {
        var deletedTask = false
        
        if t.rClass.isShared, let classKey = t.rClass.databaseKey, let taskKey = t.databaseKey {
            
            let sharedClassesPath = getSharedClassesPath()
            self.ref.child(sharedClassesPath+"/\(classKey)/\(Constants.ClassFields.tasks)/"+taskKey).removeValue()
            
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
                    self.taskDelegate?.completedTask(task, withIndexPath: indexPath);
                    break
                }
            }
        }
    }
    
    //TODO: Filter tasks if they have been completed...
    func completeTask(_ t: Task, atIndexPath indexPath: IndexPath?) {
        
        var completedTask = false
        
        if t.rClass.isShared, let classKey = t.rClass.databaseKey, let taskKey = t.databaseKey {
            
            let followedClassesPath = getFollowedClassesPath()
            self.ref.child(followedClassesPath+"/\(classKey)/\(Constants.FollowedClassFields.tasks)/"+taskKey).setValue(true)
            
            completedTask = true
            
        } else { //Task is not shared
            
            if let path = getPathForTask(t) {
                //Delete the task from the database
                self.ref.child(path).removeValue()
                completedTask = true
            }
        }
        
        if completedTask {
            //Delete the task from the tasks array
            for (i,task) in tasks.enumerated() {
                if task === t {
                    tasks.remove(at: i)
                    
                    //Send the signal to delete the task in the TaskOrganizer
                    self.taskDelegate?.completedTask(task, withIndexPath: indexPath);
                    break
                }
            }
        }
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

    //MARK: *OTHER FUNCTIONS*
    func refresh() {
        
    }
    
    func signOut() {
        self.classes.removeAll()
        self.classDelegate?.signOut()
        self.tasks.removeAll()
        self.followedClasses.removeAll()
        self.taskDelegate?.signOut()
        self.removeClassListener()
    }
    
    private func constructFollowedClass(_ c: Class, newTasks tasks: [Task]) -> Dictionary<String, Any> {
        //Construct data structure to add to database
        var followedClass = Dictionary<String, Any>()
        followedClass[Constants.FollowedClassFields.owner] = c.owner
        let completion = self.constructCompletionDictionary(tasks: tasks)
        followedClass[Constants.FollowedClassFields.tasks] = completion
        
        //Update local followedClasses structure
        self.followedClasses[c.databaseKey!] = completion
        
        return followedClass
    }
    
    private func constructCompletionDictionary(tasks: [Task]) -> Dictionary<String, Bool> {
        var completionDictionary = Dictionary<String, Bool>()
        
        for task in tasks {
            if let key = task.databaseKey {
                completionDictionary[key] = false
            }
        }
        
        return completionDictionary
    }
    
    
}
