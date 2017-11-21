//
//  AddTaskTableViewController.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/14/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class AddTaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let categories = ["Assignment", "Quiz", "Test", "Project", "Other"]
    let section0 = ["Class", "Category", "Name"]
    let section1 = ["Due Date", "When to do"]
    let section2 = ["Add Reminder"]
    let database = DatabaseManager.defaultManager
    var prevIndexPath : IndexPath?
    
    var classes = [Class]()
    var task : Task? = nil
    var indexPath : IndexPath? = nil
    var selectedClassIndex : Int = 0
    var selectedCategoryIndex : Int = 0
    var descriptionText : String = ""
    var dueDate : Date?
    var whenToDoDate : Date?
    
    private var editingDisabled = false
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil);
    }
    
    @IBAction func add(_ sender: UIBarButtonItem) {
        
        if (!editingDisabled) { //title == "Done"
            self.view.endEditing(true)
            
            var newTask = Task(classes[selectedClassIndex],
                               category: taskCategory(rawValue: categories[selectedCategoryIndex])!,
                               desc: descriptionText,
                               dueDate: dueDate,
                               todoDate: whenToDoDate)
            
            if let task = task { //Delete the task passed in
                
                //database.completeTask(task, atIndexPath: indexPath)
                newTask.reminders = task.reminders
                database.deleteTask(task, atIndexPath: indexPath);
                database.saveTask(&newTask)
                
            } else { //Save the new task
                database.saveTask(&newTask)
            }
            
            dismiss(animated: true, completion: nil);
            
        } else { //title == "Edit"
            editingDisabled = false
            addButton.title = "Done"
            self.tableView.reloadData() //Allow selection of cell content
            self.tableView.allowsSelection = true

        }
        
    }
    
    //MARK - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 44; // Some average height of your cells
        
        setupClasses()
        setupButtons()
    }
    
    private func setupButtons() {
        if editingDisabled {
            self.navigationItem.title = "Edit Task"
            cancelButton.title = "Back"
            addButton.title = "Edit"
            self.tableView.allowsSelection = false
        } else {
            if let task = task {
                addButton.title = "Done"
                
                //Disable editing if the user is not the owner of the task
                if task.rClass.owner != Auth.auth().currentUser!.uid {
                    addButton.isEnabled = false
                    self.tableView.allowsSelection = false
                }
            }
        }
    }
    
    private func setupClasses() {
        if classes.count == 0 {
            classes = database.classes.filter({ (c) -> Bool in
                c.owner == Auth.auth().currentUser!.uid
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Public Methods
    
    func configure(withTask task: Task, andIndexPath indexPath: IndexPath) {
        self.task = task
        self.indexPath = indexPath
        setupClasses()
        selectedClassIndex = indexForClass(task.rClass)
        selectedCategoryIndex = indexForCategory(task.category)
        descriptionText = task.desc
        dueDate = task.dueDate
        whenToDoDate = task.todoDate
    }
    
    func disableEditing() {
        editingDisabled = true
    }
    
    
    
    
    //MARK: Private Methods
    
    private func indexForClass(_ rClass: Class) -> Int {
        for (i,c) in classes.enumerated() {
            if c == rClass {
                return i
            }
        }
        
        return 0
    }
    
    private func indexForCategory(_ category: taskCategory?) -> Int {
        guard category != nil else {return 0}
        
        for (i,c) in categories.enumerated() {
            if c == category!.rawValue {
                return i
            }
        }
        
        return 0
    }
    
    
    // MARK: - Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        if let task = task, task.rClass.isShared == true, task.rClass.owner == Auth.auth().currentUser?.uid { //A task is being editing, it is of the shared type, and the current user is the owner.
            
            //Enable the delete task button
            return 4
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return section0.count
        } else if section == 1 {
            return section1.count
        } else if section == 2 {
            return section2.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "pickerViewTableViewCell", for: indexPath) as! PickerViewTableViewCell
                
                
                cell.configure(title: section0[indexPath.row],
                               data: classes.map({ (myClass) -> String in
                                return myClass.name}),
                               selectedRow: selectedClassIndex)
                cell.editingDisabled = editingDisabled
                cell.delegate = self
                
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "pickerViewTableViewCell", for: indexPath) as! PickerViewTableViewCell
                
                
                cell.configure(title: section0[indexPath.row],
                               data: categories,
                               selectedRow: selectedCategoryIndex)
                cell.editingDisabled = editingDisabled
                cell.delegate = self
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
                
                cell.configure(title: section0[section0.count-1],
                               textFieldText: descriptionText,
                               textFieldPlaceholder: "What do you have to do?")
                cell.editingDisabled = editingDisabled
                cell.delegate = self
                
                return cell
                
            }
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "labelTableViewCell", for: indexPath) as! LabelTableViewCell
            
            //Date Formatter
            var dateString = "-"//"--/--/---- --:-- --"
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.dateFormat = "MMMM dd,   h:mm a"
            
            //Customize Label Cell
            if indexPath.row == 0 {
                if let dueDate = dueDate {
                    dateString = dateFormatter.string(from: dueDate)
                }
                
                cell.configure(titleText: section1[indexPath.row], labelText: dateString)
            } else {
                if let whenToDoDate = whenToDoDate {
                    dateString = dateFormatter.string(from: whenToDoDate)
                }
                
                cell.configure(titleText: section1[indexPath.row], labelText: dateString)
            }
            cell.editingDisabled = editingDisabled
            
            return cell
            
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonTableViewCell", for: indexPath) as! ButtonTableViewCell
            
            cell.button.setTitle(section2[0], for: UIControlState.normal)
            cell.editingDisabled = editingDisabled
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonTableViewCell", for: indexPath) as! ButtonTableViewCell
            
            
            cell.button.setTitle("Delete Shared Task", for: UIControlState.normal)
            cell.button.tintColor = UIColor.red
            cell.delegate = self
            cell.editingDisabled = editingDisabled
            
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
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if segue.identifier == Constants.Segues.AddReminderVC {
            if let destination = segue.destination as? ReminderViewController {
                
                if (self.task == nil) {
                    self.task = Task(classes[selectedClassIndex],
                                     category: taskCategory(rawValue: categories[selectedCategoryIndex])!,
                                     desc: descriptionText,
                                     dueDate: dueDate,
                                     todoDate: whenToDoDate)
                }
                destination.task = self.task!
            }
        }
     }
    
    
    //MARK: TableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        guard !editingDisabled else {return}
        
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
            
            self.view.endEditing(true)
        }
        
        tableView.beginUpdates()
        //tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        tableView.endUpdates()
        
        prevIndexPath = indexPath
        
        
        if !editingDisabled && indexPath.section == 1 {
            let calendar = CalendarView(nibName: "CalendarView", bundle: Bundle(for: CalendarView.self))
            calendar.delegate = self
            calendar.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            
            if indexPath.row == 0 {
                if let dueDate = dueDate {
                    calendar.date = dueDate
                }
            } else if indexPath.row == 1 {
                if let whenToDoDate = whenToDoDate {
                    calendar.date = whenToDoDate
                }
            }
            
            self.present(calendar, animated: true) {
                print("Presented Calendar View")
            }
            
        }
        
    }
    
}

extension AddTaskViewController : PickerViewTableCellDelegate {
    
    func pickerCell(cell: UITableViewCell, selectedPickerIndex index: Int, inArray array: [String]) {
        if let indexPath = tableView.indexPath(for: cell) {
            if indexPath.section == 0 && indexPath.row == 0 {
                selectedClassIndex = index
                print("Changed class index to \(index)")
            } else if indexPath.section == 0 && indexPath.row == 1 {
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
    
    func textFieldCellBeganEditing(cell: UITableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
            self.tableView(tableView, didSelectRowAt: indexPath)
        }
    }
}

extension AddTaskViewController : CalendarViewDelegate {
    func selectedDate(_ date: Date) {
        if (prevIndexPath?.section == 1) {
            switch (prevIndexPath!.row) {
            case 0:
                print("Due Date: \(date)")
                dueDate = date
                tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: UITableViewRowAnimation.automatic)
            case 1:
                print("When to do: \(date)")
                whenToDoDate = date
                tableView.reloadRows(at: [IndexPath(row: 1, section: 1)], with: UITableViewRowAnimation.automatic)
            default:
                print("Calendar responding to unknown row in section 1")
            }
        }
    }
}

extension AddTaskViewController : ButtonTableViewCellDelegate {
    func buttonPressed(_ button: UIButton, forCell cell: ButtonTableViewCell) {
        if let task = task, button.titleLabel?.text == "Delete Shared Task" {
            
            let alert = UIAlertController(title: "Are you sure?", message: "This action is permanent. Any other users registered to this class will be affected.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("DELETE", comment: "Delete action"), style: UIAlertActionStyle.destructive, handler: { (action) in
                self.database.deleteTask(task, atIndexPath: self.indexPath)
                
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: { //Once to remove the AddTaskViewController
                    self.dismiss(animated: true, completion: nil) //Another time to dismiss the AddTaskViewController
                })
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: {
                print("Presented warning")
            })
        } else if button.titleLabel?.text == "Add Reminder" {
            self.performSegue(withIdentifier: Constants.Segues.AddReminderVC, sender: self)
        }
    }
}
