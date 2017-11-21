//
//  ClassesTableViewController.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/13/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit
import Firebase

class ClassesTableViewController: UITableViewController {

    let database = DatabaseManager.defaultManager
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        //Prsent an alert
        let alert = UIAlertController(title: "Add a Class", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Create a New Class", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"New Class\" alert occured.")
            
            self.performSegue(withIdentifier: "AddClassVC", sender: self)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Use a Class Code", comment: "Insert a class code"), style: .default, handler: { _ in
            NSLog("The \"Class Code\" alert occured.")
            
            
            //Present an input text field
            let textFieldAlert = UIAlertController(title: "Insert Class Code", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            
            textFieldAlert.addTextField(configurationHandler: { (textField) in
                textField.text = nil
            })
                
            textFieldAlert.addAction(UIAlertAction(title: NSLocalizedString("Add", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"Add\" alert occured.")
                
                if let code = textFieldAlert.textFields![0].text {
                    self.database.addSharedClass(key: code)
                    

                }
            }))
            textFieldAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(textFieldAlert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.leftBarButtonItem = self.editButtonItem
        database.classDelegate = self
        
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
    }
    
    deinit {
        database.removeClassListener()
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
        return database.classes.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "classTableViewCell", for: indexPath) as! ClassTableViewCell

        // Unpack class and configure the cell
        
        cell.configure(database.classes[indexPath.row])
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        self.performSegue(withIdentifier: Constants.Segues.EditClassVC, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            database.deleteClass(database.classes[indexPath.row], atIndex: indexPath.row)
            
            //tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segues.AddClassVC {
            //let addClassVC = segue.destination as! AddClassViewController
        } else if segue.identifier == Constants.Segues.EditClassVC {
            //let editClassVC = segue.destination as! AddClassViewController
            
            let editClassVC = segue.destination as! AddClass2ViewController

            
            if let row = tableView.indexPathForSelectedRow?.row {
                editClassVC.setClass(database.classes[row], withIndex: row)
            }
        }
    }

}

extension ClassesTableViewController : DatabaseManagerClassDelegate {
    func addedClass(class: Class) {
        //tableView.reloadData()
        
        //self.tableView.insertRows(at: [IndexPath(row: self.database.classes.count-1, section: 0)], with: UITableViewRowAnimation.automatic)
        self.tableView.reloadData()
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }

    }
    
    func deletedClass(_ c: Class, atIndex index: Int) {
        print("Deleted class \(c.name)")

        
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
        
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    func addedSharedClass(code: String, newClass: Class?, customErrorMessage msg: String?) {
        var text = "Failure"
        var message = msg ?? "Unknown error occured"
        
        if let newClass = newClass {
            text = "Success"
            message = "You have successfully downloaded the shared class '\(newClass.name)'"
        }
        
        let resultAlert = UIAlertController(title: text, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        resultAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            print("User accepted results")
        }))
        
        self.present(resultAlert, animated: true, completion: nil)
    }
    
    func signOut() {
        self.tableView.reloadSections(IndexSet([0]), with: UITableViewRowAnimation.automatic)
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    func reloadClass(index: Int) {
        //self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
        self.tableView.reloadData()
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }

}
