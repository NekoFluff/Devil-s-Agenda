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

protocol DatabaseManagerReminderDelegate {
    func addedReminder(_ r : Reminder);
    func deletedReminder(_ r : Reminder, atIndex index: Int);
}


// Swift 3:
class AtomicCounter {
    private var queue = DispatchQueue(label: "AtomicCounterQueue");
    private (set) var totalClasses: Int = 0
    private (set) var downloadedClasses: Int = 0
    
    
    func incrementTotalClasses(_ val: Int) {
        queue.sync {
            totalClasses += val
        }
    }
    
    func incrementDownloadedClasses(_ val: Int) {
        queue.sync {
            downloadedClasses += val
        }
    }
    
    func reset() {
        queue.sync {
            totalClasses = 0
            downloadedClasses = 0
        }
    }
}

class DatabaseManager {
    
    static let defaultManager = DatabaseManager()
    private var DatabaseManagerQueue = DispatchQueue(label: "databaseManagerQueue");
    var classDelegate : DatabaseManagerClassDelegate?
    var taskDelegate : DatabaseManagerTaskDelegate?
    var addClassDelegate : DatabaseManagerAddClassDelegate?
    var reminderDelegate : DatabaseManagerReminderDelegate?
    var classDelegateForSchedule : DatabaseManagerClassDelegate?
    
    var classes = [Class]()
    var tasks = NSPointerArray(options: NSPointerFunctions.Options.weakMemory)
    var followedClasses = Dictionary<String, Dictionary<String, Bool>>()
    
    private var ref : DatabaseReference!
    private var _classRefHandle : DatabaseHandle?
    private let atomicCounter = AtomicCounter()
    
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
            if let newTasksData = classData[Constants.ClassFields.tasks] as? Dictionary<String, [String : Any]> {
                for (taskKey, taskData) in newTasksData {
                    
                    //Only create a new task if it hasn't already been completed
                    if (newClass.isShared) {
                        if let classCompletionInfo = followedClasses[snapshot.key], let isCompleted = classCompletionInfo[taskKey] {
                            
                            if isCompleted {continue}
                        }
                    }
                    
                    
                    let newTask = Task(newClass, data: taskData, databaseKey: taskKey)
                    tasks.addObject(newTask)
                    newClass.addTask(newTask, forKey: newTask.desc);
                    
                    newTasks.append(newTask)
                    taskDelegate?.addedTask(newTask)
                }
            }
            return (newClass, newTasks)
        }
        return nil
    }
    
    func downloadClasses(update: @escaping (_ current: Int,_ max: Int, Bool, Bool) -> ()) {
        downloadFollowedClasses(update: update)
        addClassListener(update: update)
    }
    
    private func downloadFollowedClasses(update: @escaping (_ current: Int,_ max: Int, Bool, Bool) -> ()) {
        
        self.getClassCount { (count) in
            let isZero = count == 0;
            update(self.atomicCounter.downloadedClasses, self.atomicCounter.totalClasses, false, isZero)
            self.atomicCounter.incrementTotalClasses(count)
        }
        
        let followedClassesPath = getFollowedClassesPath()
        
        //Get all the followedClasses
        self.ref.child(followedClassesPath).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            print("Downloading shared classes")
            
            //Unwrap the data
            if let followedClassesData = snapshot.value as? Dictionary<String, Any> {
                self.atomicCounter.incrementTotalClasses(followedClassesData.values.count)
                
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
                        
                        self.atomicCounter.incrementDownloadedClasses(1)
                        
                        //Create a class for every followed class
                        self.DatabaseManagerQueue.sync {
                            update(self.atomicCounter.downloadedClasses, self.atomicCounter.totalClasses, true, false)
                            if let (newClass, _) = self.createClass(fromSnapshot: snapshot2) {
                                self.classDelegate?.addedClass(class: newClass)
                                self.classDelegateForSchedule?.addedClass(class: newClass)
                            }
                        }
                    })
                }
                
            } else {
                print("No followed classes")
                update(self.atomicCounter.downloadedClasses, self.atomicCounter.totalClasses, true, false)
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
    
    func addClassListener(update: @escaping (_ current: Int,_ max: Int, Bool, Bool) -> ()) {
        guard _classRefHandle == nil else {return}
        
        //Listen for new class additions in the Firebase database
        _classRefHandle = self.ref.child("users").child(Auth.auth().currentUser!.uid).child("classes").observe(DataEventType.childAdded, with: { [weak self](snapshot) in
            guard let strongSelf = self else { return }
            
            print("Adding new class")
            strongSelf.DatabaseManagerQueue.sync {
                
                //TODO: Better way to find class. Idea: dictionary of array of classes
                for c in strongSelf.classes {
                    if c.databaseKey == snapshot.key {
                        return;
                    }
                }
                
                if let (newClass, _) = strongSelf.createClass(fromSnapshot: snapshot) {
                    strongSelf.classDelegate?.addedClass(class: newClass)
                    strongSelf.classDelegateForSchedule?.addedClass(class: newClass)
                    strongSelf.atomicCounter.incrementDownloadedClasses(1)
                    update(strongSelf.atomicCounter.downloadedClasses, strongSelf.atomicCounter.totalClasses, false, true)
                }
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
    
    //MARK: - CLASS Methods
    func getClassCount(f: @escaping (Int)->()) {
        ref.child("users/\(Auth.auth().currentUser!.uid)/classes/count").observe(.value, with: { (snapshot) in
            if let count = snapshot.value as? Int {
                f(count)
            }
        })
    }
    
    func changeClassCountBy(increment: Int) {
        ref.child("users/\(Auth.auth().currentUser!.uid)/classes/count").runTransactionBlock({ (data) -> TransactionResult in
            
            var count = data.value as? Int ?? 0
            count = count + increment;
            data.value = count;

            return TransactionResult.success(withValue: data)

        }, andCompletionBlock: { (error, aBool, snapshot) in
            print(error?.localizedDescription ?? "No error", aBool, snapshot ?? "No snapshot")
        })
    }
    
    func saveClass(_ c: Class) {
        guard !c.isShared else {saveSharedClass(c); return}
        
        var classPath = self.ref.child("users").child(Auth.auth().currentUser!.uid).child("classes")
        
        if c.databaseKey == nil {
            classPath = classPath.childByAutoId()
            c.databaseKey = classPath.key
            changeClassCountBy(increment: 1)

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
                changeClassCountBy(increment: -1)
                
//                //Delete all tasks associated with that task
//                tasks = tasks.filter({ (task) -> Bool in
//                    task.rClass != classes[i]
//                })
                
                //Delete the class
                let deletedClass = classes.remove(at: i)
                
                //Send signals
                self.taskDelegate?.deletedClass(deletedClass)
                self.classDelegate?.deletedClass(deletedClass, atIndex: i)
                self.classDelegateForSchedule?.deletedClass(deletedClass, atIndex: i)
            }
        }
    }
    
    //MARK: - SHARED CLASS Methods
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
            
//            //Delete all tasks associated with that task
//            tasks = tasks.filter({ (task) -> Bool in
//                task.rClass != c
//            })
            
            //Delete the class
            let deletedClass = classes.remove(at: index)
            
            //Delete the class from the followedClasses
            followedClasses[classKey] = nil
            
            //Send signals
            self.taskDelegate?.deletedClass(deletedClass)
            self.classDelegate?.deletedClass(deletedClass, atIndex: index)
            self.classDelegateForSchedule?.deletedClass(deletedClass, atIndex: index)
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
                self.classDelegateForSchedule?.addedClass(class: newClass)
                //self.classDelegateForSchedule?.addedSharedClass(code: key, newClass: newClass, customErrorMessage: nil)
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
        
        //DONE - TODO: Get the data from the stabase using an observe single instance method call. (Use information from old class (c)
        //DONE - TODO: Update the data with information from the new class (c2)
        //DONE - TODO: Delete the old data in the database and replace it with the updated data
        //DONE - TODO: Under the circumstance that the 'isShared' value did not change, do not delete the old data. (Simply update it with the updated data)
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
                data[Constants.ClassFields.name] = c2.name;
                data[Constants.ClassFields.color] = c2.color;
                data[Constants.ClassFields.key] = c2.databaseKey;
                data[Constants.ClassFields.shared] = c2.isShared;
                
                data[Constants.ClassFields.professor] = c2.professor;
                data[Constants.ClassFields.location] = c2.location;
                data[Constants.ClassFields.daysOfTheWeek] = c2.daysOfTheWeek;
                
                let df = DateFormatter()
                df.dateFormat = "HH:mm:ss"
                
                if let start = c2.startTime {
                    data[Constants.ClassFields.startTime] = df.string(from: start)
                }
                
                if let end = c2.endTime {
                    data[Constants.ClassFields.endTime] = df.string(from: end)
                }
                
                
                //Delete shared data if both classes aren't shared and the keys don't match
                if (!(c.isShared == c2.isShared && c.databaseKey == c2.databaseKey)) {
                    self.ref.updateChildValues([oldLocation : []])
                }
                
                //Write shared data in new location
                if (c.isShared && !c2.isShared) {
                    //todo: generate new key and use it for data
                    var classPath = self.ref.child("users").child(Auth.auth().currentUser!.uid).child("classes")
                    
                    
                    classPath = classPath.childByAutoId()
                    c2.databaseKey = classPath.key
                    classPath.setValue(data);
                
                    //make sure the database keys are different beforehand
                } else {
                    //Default write
                    self.ref.updateChildValues([newLocation : data])

                }

                //Re-write personal data
                let followedClassesPath = self.getFollowedClassesPath()
                if c.isShared && c2.isShared {
                    //Update the database
                    //DONE - TODO: Move followed class data...
                    //DONE - TODO: Get followed class data from database
                    //DONE - TODO: Even if you're not the owner, you should still be able to edit the class code field to move the your existing data.
                    
                    print("Shared -> Shared. Moving old data to new location")
                    
                    //Get data in old location
                    self.ref.child(followedClassesPath+"/"+classCode).observeSingleEvent(of: DataEventType.value, with: { (snapshot2) in
                        
                        if let oldData = snapshot2.value as? Dictionary<String, Any?> {
                            //Move the data
                            
                            if c2.databaseKey != classCode {
                                self.ref.updateChildValues([followedClassesPath+"/"+c2.databaseKey! : oldData, followedClassesPath+"/"+classCode : []])
                            } else {
                                self.ref.updateChildValues([followedClassesPath+"/"+c2.databaseKey! : oldData])
                            }
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
                            newTasks.append(array[i])
                        }
                    }
                    
                    //Construct followed class
                    let followedClass = self.constructFollowedClass(c, newTasks: newTasks)
                    
                    //Add the class to the database
                    self.ref.updateChildValues([followedClassesPath+"/"+c2.databaseKey! : followedClass])
                    
                    //Decrement number of non-shared classes
                    self.changeClassCountBy(increment: -1)

                } else if (c.isShared && !c2.isShared) {
                    print("Shared -> Non-Shared. Deleting old followed class")
                    //Delete followed class from database
                    self.ref.child(followedClassesPath+"/"+classCode).removeValue()
                    
                    //Delete followed class
                    self.followedClasses[classCode] = nil
                    
                    //Increment number of non-shared classes
                    self.changeClassCountBy(increment: 1)
                    
                } else {
                    print("Non-shared -> Non-shared. No followed class update necessary")
                }
                
                self.DatabaseManagerQueue.sync {
                    c.name = c2.name;
                    c.databaseKey = c2.databaseKey;
                    c.color = c2.color;
                    c.isShared = c2.isShared;
                    
                    c.professor = c2.professor;
                    c.location = c2.location;
                    c.startTime = c2.startTime;
                    c.endTime = c2.endTime;
                    
                    c.daysOfTheWeek = c2.daysOfTheWeek;
                    
                    self.classDelegate?.reloadClass(index: index);
                    self.classDelegateForSchedule?.reloadClass(index: index)
                }
                
                self.DatabaseManagerQueue.sync {
                    self.taskDelegate?.reloadTasks();
                }
            }
        })
        

    }
    
    func checkIfSharedClassExists(classCode: String) {
        let sharedClassesPath = getSharedClassesPath()
        self.ref.child(sharedClassesPath+"/\(classCode)").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            self.addClassDelegate?.classCodeExists(classCode, exists: snapshot.exists());
            
        })
    }

    
    //MARK: - TASK Methods
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
                self.tasks.addObject(t)
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
            for i in 0..<tasks.count {
                let task = tasks.object(at: i) as! Task
                if task === t {
                    tasks.removeObject(at: i)
                    
                    //Send the signal to delete the task in the TaskOrganizer
                    self.taskDelegate?.completedTask(task, withIndexPath: indexPath);
                    break
                }
            }
            
            t.rClass.removeTask(t)
        }
    }
    
    //DONE - TODO: Filter tasks if they have been completed...
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
//            //Delete the task from the tasks array
//            for (i,task) in tasks.enumerated() {
//                if task === t {
//                    tasks.remove(at: i)
//                    
//                    //Send the signal to delete the task in the TaskOrganizer
//                    self.taskDelegate?.completedTask(task, withIndexPath: indexPath);
//                    break
//                }
//            }
            t.rClass.removeTask(t)
            self.taskDelegate?.completedTask(t, withIndexPath: indexPath)
        }
    }
    
    //MARK: - Reminder Methods
    func saveReminder(_ r: Reminder) {

        let _ = NotificationsHandler.defaultHandler.setReminder(r)
        
        //Determine save path
        var path : String?
        if r.task.rClass.isShared {
            path = getSharedClassesPath()+"/\(r.task.rClass.databaseKey!)/\(Constants.ClassFields.tasks)/"
        } else {
            path = getTasksPath(r.task.rClass)
        }
        
        if let path = path {
            let data = r.toDict()
            if let taskKey = r.task.databaseKey, let reminderKey = r.databaseKey { //Update a reminder
                
                self.ref.updateChildValues([path+"/"+taskKey+"/\(Constants.TaskFields.reminders)/\(reminderKey)" : data])
            }
        }
        
        self.reminderDelegate?.addedReminder(r);
    }
    
    func deleteReminder(_ r: Reminder, atIndex index: Int) -> Bool {
        guard (index < r.task.reminders.count) else {return false;}

        NotificationsHandler.defaultHandler.deleteReminder(r)
        
        var deletedReminder = false
        if (r.databaseKey == nil) {print("ERROR: No database key for reminder!")}
            
        if r.task.rClass.isShared, let classKey = r.task.rClass.databaseKey, let taskKey = r.task.databaseKey, let reminderKey = r.databaseKey {
            
            let sharedClassesPath = getSharedClassesPath()
            self.ref.child(sharedClassesPath+"/\(classKey)/\(Constants.ClassFields.tasks)/"+taskKey+"/\(Constants.TaskFields.reminders)/\(reminderKey)").removeValue()
            
            deletedReminder = true
            
        } else { //Task is not shared
            
            if let path = getPathForTask(r.task), let reminderKey = r.databaseKey {
                //Delete the task from the database
                self.ref.child(path+"/\(Constants.TaskFields.reminders)/\(reminderKey)").removeValue()
                deletedReminder = true
            }
        }
        
        if deletedReminder {
            r.task.reminders.remove(at: index)
            self.reminderDelegate?.deletedReminder(r, atIndex: index);
            return true
        } else {
            r.task.reminders.remove(at: index)
            self.reminderDelegate?.deletedReminder(r, atIndex: index);
            return false
        }
        
    }
    
    //MARK: - Get Paths
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

    //MARK: - *OTHER FUNCTIONS*
    func refresh() {
        
    }
    
    func signOut() {
        self.removeClassListener()
        self.classes.removeAll()
        self.classDelegate?.signOut()
        self.classDelegateForSchedule?.signOut()
        self.tasks.compact()
        self.followedClasses.removeAll()
        self.taskDelegate?.signOut()
        self.taskDelegate?.reloadTasks()
        self.atomicCounter.reset()
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
