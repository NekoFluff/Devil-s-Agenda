//
//  AddTaskTableViewController.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/14/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit
import Firebase

class AddTaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let categories = ["Assignment", "Quiz", "Test", "Project", "Other"]
    let section0 = ["Class", "Category", "Name"]
    let section1 = ["Due Date", "When to do"]
    let section2 = ["Add Reminder"]
    let database = DatabaseManager.defaultManager
    var prevIndexPath : IndexPath?
    
    var selectedClassIndex : Int = 0
    var selectedCategoryIndex : Int = 0
    var descriptionText : String = ""
    //var delegate : AddTaskViewControllerDelegate?
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil);
    }
    
    @IBAction func add(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil);
        
        if let classKey = database.classes[selectedClassIndex].databaseKey {
            let newTask = Task(database.classes[selectedClassIndex],
                               category: taskCategory(rawValue: categories[selectedCategoryIndex]) ?? taskCategory(rawValue: "Assignment")!,
                               desc: descriptionText)
            database.tasks.append(newTask)
            database.saveTask(forClass: classKey,
                              withData: newTask.toDict())
            
            
            //self.delegate?.addedNewTask(task: newTask)
        } else {
            print("ERROR: Class key missing!")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 44; // Some average height of your cells
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return section0.count
        } else if section == 1 {
            return section1.count
        } else if section == 2 {
            return section2.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "pickerViewTableViewCell", for: indexPath) as! PickerViewTableViewCell
                
                cell.delegate = self
                cell.title.text = section0[indexPath.row]
                cell.pickerData = database.classes.map({ (myClass) -> String in
                    return myClass.name
                })
                cell.picker.selectRow(selectedClassIndex, inComponent: 0, animated: false)
                
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "pickerViewTableViewCell", for: indexPath) as! PickerViewTableViewCell
                
                cell.delegate = self
                cell.title.text = section0[indexPath.row]
                cell.pickerData = categories
                cell.picker.selectRow(selectedCategoryIndex, inComponent: 0, animated: false)
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
                
                cell.title.text = section0[section0.count-1]
                cell.textField.placeholder = "What do you have to do?"
                cell.textField.text = descriptionText
                cell.delegate = self
                
                return cell

            }
        } else if indexPath.section == 1 {
            //TODO: Date Picker!!!
            let cell = tableView.dequeueReusableCell(withIdentifier: "pickerViewTableViewCell", for: indexPath) as! PickerViewTableViewCell
            cell.delegate = self
            
            if indexPath.row == 0 {
                cell.title.text = section1[indexPath.row]
                cell.pickerData = ["a","b","c","d","e"]
            } else {
                cell.title.text = section1[indexPath.row]
                cell.pickerData = ["a","b","c","d","e"]
            }
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonTableViewCell", for: indexPath) as! ButtonTableViewCell
            
            cell.button.setTitle(section2[0], for: UIControlState.normal)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pickerViewTableViewCell", for: indexPath) as! PickerViewTableViewCell
            cell.delegate = self
            cell.title.text = "error"
            cell.pickerData = ["a","b","c","d","e"]
            
            return cell
        }

    }
    
 
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let prevI = prevIndexPath, let prevPickerCell = tableView.cellForRow(at: prevI) as? PickerViewTableViewCell {
            if (prevIndexPath != indexPath && prevPickerCell.showsDetails) {
                prevPickerCell.showsDetails = !prevPickerCell.showsDetails
                
                UIView.animate(withDuration: 0.3) {
                    prevPickerCell.contentView.layoutIfNeeded() // Or self.contentView if you're doing this from your own cell subclass
                }
            }
        }
        
        if let pickerCell = tableView.cellForRow(at: indexPath) as? PickerViewTableViewCell {
            pickerCell.showsDetails = !pickerCell.showsDetails;
            

            UIView.animate(withDuration: 0.3) {
                pickerCell.contentView.layoutIfNeeded() // Or self.contentView if you're doing this from your own cell subclass
            }
            
        }
    
        tableView.beginUpdates()
        //tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        tableView.endUpdates()
        
        prevIndexPath = indexPath
        
        self.present(CalendarView(), animated: true) {
            print("Presented Calendar View")
        }
    }
    
}

extension AddTaskViewController : PickerViewTableCellDelegate {
    
    func pickerCell(cell: UITableViewCell, selectedPickerIndex index: Int, inArray array: [String]) {
        if let indexPath = tableView.indexPath(for: cell) {
            if indexPath.section == 1 && indexPath.row == 0 {
                selectedClassIndex = index
                print("Changed class index to \(index)")
            } else if indexPath.section == 1 && indexPath.row == 1 {
                selectedCategoryIndex = index
                print("Changed category index to \(index)")
            }
        }
    }
}






extension AddTaskViewController : TextFieldTableCellDelegate {
    func textFieldCell(cell: UITableViewCell, changedText text: String) {
        self.descriptionText = text;
        print("New description text: " + text)
    }
}
