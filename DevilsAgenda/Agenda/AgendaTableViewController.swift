//
//  AgendaTableViewController.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/13/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit
import Firebase

class AgendaTableViewController: UITableViewController {

    let database = DatabaseManager.defaultManager
    let taskOrganizer = TaskOrganizer.defaultOrganizer
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        if database.classes.count == 0 {
            let alert = UIAlertController(title: "No Classes", message: "Add a class in the Classes tab before adding a task!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: Constants.Segues.AddTaskVC, sender: self)
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.leftBarButtonItem = self.editButtonItem

        taskOrganizer.delegate = self
        
        tableView.allowsSelectionDuringEditing = true
        
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
    }
    
    deinit {
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 10
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch(section) {
        case 0:
            return taskOrganizer.countForSection(taskSection.overdue)
        case 1, 2, 3, 4, 5, 6, 7:
            if let taskSection = taskSectionForIndexPath(IndexPath(row: 0, section: section)) {
                return taskOrganizer.countForSection(taskSection)
            } else {
                return 0
            }
        case 8:
            return taskOrganizer.countForSection(taskSection.later)
        case 9:
            return taskOrganizer.countForSection(taskSection.tbd)
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskTableViewCell", for: indexPath) as! TaskTableViewCell

        if let myTask = taskForIndexPath(indexPath) {
            cell.configure(task: myTask)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let taskSection = taskSectionForIndexPath(IndexPath(row: 0, section: section)) {
            if taskOrganizer.countForSection(taskSection) == 0 {return nil}
        }
        
        switch(section) {
        case 0:
            return taskSection.overdue.rawValue
        case 1:
            return "Today"
        case 2:
            return "Tomorrow"
        case 3, 4, 5, 6, 7:
            return taskSectionForIndexPath(IndexPath(row: 0, section: section))?.rawValue ?? nil
        case 8:
            return taskSection.later.rawValue
        case 9:
            return taskSection.tbd.rawValue
        default:
            return nil
        }
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            database.completeTask(database.tasks[indexPath.row], atIndexPath: indexPath)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }    
//    }
 
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
        }
        
        let complete = UITableViewRowAction(style: .normal, title: "Complete") { (action, indexPath) in
            // share item at indexPath
            
            if let task = self.taskForIndexPath(indexPath) {
                self.database.completeTask(task , atIndexPath: indexPath)
                
                //tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }
        }
        
        complete.backgroundColor = UIColor.green
        
        return [complete]
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    //In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == Constants.Segues.AddTaskVC {
//            if let dest = segue.destination as? AddTaskViewController {
//                
//            }
//        }
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let taskVC = storyboard?.instantiateViewController(withIdentifier: "addTaskViewController") as? AddTaskViewController {
            
            if let task = taskForIndexPath(indexPath) {
                taskVC.configure(withTask: task, andIndexPath: indexPath)
                
                if !tableView.isEditing {
                    taskVC.disableEditing()
                }
                
                self.present(taskVC, animated: true, completion: {
                    print("Presented taskVC")
                })
            }
        }
    }
    
    private func taskForIndexPath(_ indexPath: IndexPath) -> Task? {
        if let section = taskSectionForIndexPath(indexPath)?.rawValue, let tasks = taskOrganizer.organizedTasks[section] {
            return tasks.object(at: indexPath.row) as? Task
        }
        return nil
    }
    
    private func taskSectionForIndexPath(_ indexPath: IndexPath) -> taskSection? {
        switch(indexPath.section) {
        case 0: //Overdue
            return taskSection.overdue
        case 1: //Today
            return taskOrganizer.getTaskSectionForDate(taskOrganizer.date)
        case 2: //Tomorrow
            return taskOrganizer.getTaskSectionForDate(taskOrganizer.date.add(components: [.day : 1]))
        case 3: //Tomorrow + 1
            return taskOrganizer.getTaskSectionForDate(taskOrganizer.date.add(components: [.day : 2]))
        case 4: //Tomorrow + 2
            return taskOrganizer.getTaskSectionForDate(taskOrganizer.date.add(components: [.day : 3]))
        case 5: //Tomorrow + 3
            return taskOrganizer.getTaskSectionForDate(taskOrganizer.date.add(components: [.day : 4]))
        case 6: //Tomorrow + 4
            return taskOrganizer.getTaskSectionForDate(taskOrganizer.date.add(components: [.day : 5]))
        case 7: //Tomorrow + 5
            return taskOrganizer.getTaskSectionForDate(taskOrganizer.date.add(components: [.day : 6]))
        case 8: //Later
            return taskSection.later
        case 9: //To be determined
            return taskSection.tbd
        default:
            return nil
        }
    }
    
}

extension AgendaTableViewController : TaskOrganizerDelegate {
    func reloadTasks() {
        self.tableView.reloadData()
    }

    func completedTask(_ task: Task, inSection section: taskSection, andIndexPath indexPath: IndexPath?) {

        if let indexPath = indexPath, (self.tableView.cellForRow(at: indexPath) as! TaskTableViewCell).task == task {
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            print("Deleted task using indexPath \(indexPath)")
        } else {
            self.tableView.reloadSections(IndexSet([self.sectionForTaskSection(section)]), with: UITableViewRowAnimation.automatic)
            print("Reloaded table view section \(section) to delete task")
        }
        //tableView.reloadRows(at: [IndexPath(row: index, section: sectionForTaskSection(section))], with: UITableViewRowAnimation.automatic)
        
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }

    func deletedClass(_ class: Class) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func addedTask(_ task: Task, toSection section: taskSection, withIndex index: Int) {
        
        
        let section = self.sectionForTaskSection(section)
        //tableView.beginUpdates()
        //tableView.reloadSections(IndexSet([section]), with: UITableViewRowAnimation.automatic)
        self.tableView.insertRows(at: [IndexPath(row: index, section: section)], with: UITableViewRowAnimation.automatic)
        //tableView.endUpdates()
        
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        
    }
    
    func updatedTask(_ task: Task, inSection section: taskSection) {
        
        tableView.reloadSections(IndexSet([sectionForTaskSection(section)]), with: UITableViewRowAnimation.automatic)
        //tableView.reloadRows(at: [IndexPath(row: index, section: sectionForTaskSection(section))], with: UITableViewRowAnimation.automatic)
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    private func sectionForTaskSection(_ ts: taskSection) -> Int {
        switch(ts) {
        case .overdue:
            return 0
        case .monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday:
            if let weekday = taskOrganizer.weekdayForTaskSection(ts) {
                for (i) in 0 ..< 7 {
                    if (taskOrganizer.date.add(components: [.day : i]).weekday == weekday.rawValue) {
                        print("i+1: \(i+1)")
                        return i+1
                    }
                }
            }
            return 0
        case .later:
            return 8
        case .tbd:
            return 9
        }
        
    }
}


