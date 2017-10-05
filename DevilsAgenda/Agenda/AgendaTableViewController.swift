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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        database.taskDelegate = self
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return database.tasks.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskTableViewCell", for: indexPath) as! TaskTableViewCell

        let myTask = database.tasks[indexPath.row]
        // Configure the cell...
        cell.colorView.backgroundColor = uicolorForString(str: myTask.rClass.color)
        cell.titleLabel.text = myTask.desc
        cell.subtitleLabel.text = myTask.rClass.name
        cell.dateLabel.text = "1/1/11"
        
        return cell
    }
    
    private func uicolorForString(str: String) -> UIColor{
        switch (str) {
        case "Red":
            return UIColor.red
        case "Green":
            return UIColor.green
        case "Blue":
            return UIColor.blue
        case "Orange":
            return UIColor.orange
        case "Yellow":
            return UIColor.yellow
        case "Black":
            return UIColor.black
        default:
            return UIColor.black
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == Constants.Segues.AddTaskVC {
//            if let dest = segue.destination as? AddTaskViewController {
//                dest.delegate = self
//            }
//        }
//    }
    

}

extension AgendaTableViewController : DatabaseManagerTaskDelegate {
    func addedTask() {
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: database.tasks.count-1, section: 0)], with: UITableViewRowAnimation.automatic)
        tableView.endUpdates()
    }
}



