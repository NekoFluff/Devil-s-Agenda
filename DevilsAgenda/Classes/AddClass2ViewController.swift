//
//  AddClassTableViewController.swift
//  DevilsAgenda
//
//  Created by Alexander Nou on 11/20/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//


import UIKit
import Firebase
import UserNotifications

class AddClass2ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let section0 = ["Name", "Color"] //Required
    let section1 = ["Professor", "Location", "Start Time", "End Time"] //Optional
    let section2 = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    let section3 = ["Shared"]
    let section4 = ["Delete Class"]
    
    let colorOptions = ["Red", "Green", "Blue", "Orange", "Yellow", "Black"]
    var selectedDay = [false, false, false, false, false, false, false]
    
    private let timeFormatter : DateFormatter = {
        var formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "h:mm a"
        return formatter;
    }()
    
    public let database = DatabaseManager.defaultManager
    public var _class : Class?;
    public var index : Int?;
    private var editingDisabled = false
    var prevIndexPath : IndexPath?
    
    
    //MARK: - Class-specific values
    //Required
    public var className : String?
    public var classColor = "Red"

    //Optional
    public var classProfessor : String?
    public var classLocation : String?
    public var classStartTime : Date?
    public var classEndTime : Date?
    
    //Share
    public var shareSwitchIsOn = false
    public var classCodeText : String!
    //MARK: -
    
    
    
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil);
    }
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBAction func done(_ sender: UIBarButtonItem) {
        
        if self.addButton.title == "Edit" {
            
            self.editingDisabled = false;
            self.tableView.allowsSelection = true
            self.tableView.reloadData();
            self.addButton.title = "Done";
            
        } else if self.addButton.title == "Done" {
            self.view.endEditing(true)
            
            var canSave = false;
            
            //Trying to save with a different class code
            let hasDifferentClassCode = (classCodeText != _class?.databaseKey)
            
            //The class code is different and you are still trying to save as a shared class
            if shareSwitchIsOn && hasDifferentClassCode {
                database.checkIfSharedClassExists(classCode: classCodeText)
            } else {
                canSave = true;
            }
            
            if canSave {
                saveAndExit();
            }
        } else {
            saveAndExit();
        }
    }
    
    
    //MARK - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        database.addClassDelegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 44; // Some average height of your cells
        
        setupButtons()
        updateFields()
    }
    
    private func setupButtons() {
        if editingDisabled {
            self.navigationItem.title = "Edit Class"
            cancelButton.title = "Back"
            addButton.title = "Edit"
            self.tableView.allowsSelection = false
        } else {
            if let _class = _class {
                addButton.title = "Done"
                
                //Disable editing if the user is not the owner of the task
                if _class.owner != Auth.auth().currentUser!.uid {
                    addButton.isEnabled = false
                    self.tableView.allowsSelection = false
                }
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Private Methods
    public func saveAndExit() {
        //Construct the new class
        let newClass = Class(name: className ?? "", color: classColor, owner: Auth.auth().currentUser!.uid, professor: classProfessor, location: classLocation, startTime : classStartTime, endTime : classEndTime, daysOfTheWeek: selectedDay, shared: shareSwitchIsOn)
        
        if (shareSwitchIsOn) {
            newClass.databaseKey = classCodeText
        } else {
            newClass.databaseKey = _class?.databaseKey
        }
        
        if var c = _class, let i = index {
            //database.deleteClass(c, atIndex: i)
            self.database.updateClass(&c, atIndex: i, toClass: newClass)
        } else {
            database.saveClass(newClass)
        }
        dismiss(animated: true, completion: nil);
    }
    
    private func updateFields() {
        if let c = _class {
            
            //Update all the fields
            self.navigationItem.title = "Class Info"
            self.addButton.title = "Edit"
            self.className = c.name;
            self.classColor = c.color
            self.classProfessor = c.professor
            self.classLocation = c.location
            self.classStartTime = c.startTime
            self.classEndTime = c.endTime
            self.shareSwitchIsOn = c.isShared
            
            if let days = c.daysOfTheWeek {
                self.selectedDay = days
            }
            
            if c.isShared {
                self.classCodeText = c.databaseKey
            }
            
            if c.owner != Auth.auth().currentUser!.uid {
                self.addButton.isEnabled = false;
            }
        }
    }
    
    private func rowForColor(_ color : String) -> Int {
        switch color {
        case "Red":
            return 0;
        case "Green":
            return 1;
        case "Blue":
            return 2;
        case "Orange":
            return 3;
        case "Yellow":
            return 4;
        default:
            return 5;
        }
    }
    
    //MARK: - Public Methods
    func setClass(_ c : Class, withIndex index : Int) {
        self._class = c
        self.index = index;
    }
    
    func disableEditing() {
        editingDisabled = true
    }
    
//    private func indexForClass(_ rClass: Class) -> Int {
//        for (i,c) in classes.enumerated() {
//            if c == rClass {
//                return i
//            }
//        }
//        
//        return 0
//    }
//    
//    private func indexForCategory(_ category: taskCategory?) -> Int {
//        guard category != nil else {return 0}
//        
//        for (i,c) in categories.enumerated() {
//            if c == category!.rawValue {
//                return i
//            }
//        }
//        
//        return 0
//    }
    
    
    // MARK: - Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return section0.count //Required (Name/Color)
        } else if section == 1 {
            return section1.count //Optional (Professor/Location/Start Time/End Time)
        } else if section == 2 {
            return section2.count
        } else if section == 3 {
            return section3.count + (shareSwitchIsOn == true ? 1 : 0) //Class Code
        } else if section == 4 {
            return section4.count
        }
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 { //Required
            
            if indexPath.row == 0 { // Name
                let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
                
                cell.configure(title: section0[indexPath.row],
                               textFieldText: className ?? "",
                               textFieldPlaceholder: "What's the name of your class?")
                cell.editingDisabled = editingDisabled
                cell.delegate = self
                
                return cell
            } else { // Color
                let cell = tableView.dequeueReusableCell(withIdentifier: "pickerViewTableViewCell", for: indexPath) as! PickerViewTableViewCell
                
                
                cell.configure(title: section0[indexPath.row],
                               data: colorOptions,
                               selectedRow: rowForColor(classColor))
                cell.editingDisabled = editingDisabled
                cell.delegate = self
                
                return cell
            }
        } else if indexPath.section == 1 { //Optional
            //Date Formatter
            var dateString = "-"

            
            //Customize Label Cell
            if indexPath.row == 0 { //Professor
                let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
                
                cell.configure(title: section1[indexPath.row],
                               textFieldText: classProfessor ?? "",
                               textFieldPlaceholder: "What's the professor's name?")
                cell.editingDisabled = editingDisabled
                cell.delegate = self
                
                return cell
                
            } else if indexPath.row == 1 { //Location
                let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
                
                cell.configure(title: section1[indexPath.row],
                               textFieldText: classLocation ?? "",
                               textFieldPlaceholder: "Where is the class located?")
                cell.editingDisabled = editingDisabled
                cell.delegate = self
                
                return cell
            } else if indexPath.row == 2 { //Start Time
                let cell = tableView.dequeueReusableCell(withIdentifier: "datePickerViewTableViewCell", for: indexPath) as! DatePickerViewTableViewCell
                cell.delegate = self
                
                if let startTime = classStartTime {
                    
                    cell.configure(title: section1[indexPath.row], date: startTime, formatter: timeFormatter);
                } else {
                    cell.configure(title: section1[indexPath.row],  formatter: timeFormatter);
                }
                
                cell.editingDisabled = editingDisabled
                return cell
                
            } else { //End Time
                let cell = tableView.dequeueReusableCell(withIdentifier: "datePickerViewTableViewCell", for: indexPath) as! DatePickerViewTableViewCell
                cell.delegate = self
                
                if let endTime = classEndTime {
                    
                    cell.configure(title: section1[indexPath.row], date: endTime, formatter: timeFormatter);
                } else {
                    cell.configure(title: section1[indexPath.row],formatter: timeFormatter);
                }
                
                cell.editingDisabled = editingDisabled
                return cell
            }

            
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "labelTableViewCell", for: indexPath) as! LabelTableViewCell
            
            cell.configure(titleText: section2[indexPath.row], labelText: "")
            cell.editingDisabled = editingDisabled
            
            if selectedDay[indexPath.row] {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
            
            return cell
        } else if indexPath.section == 3 { //Shared
            
            if (indexPath.row == 0) { //Share Switch
                let cell = tableView.dequeueReusableCell(withIdentifier: "switchTableViewCell", for: indexPath) as! SwitchTableViewCell
                
                cell.configure(title: section3[indexPath.row], isOn: shareSwitchIsOn)
                cell.editingDisabled = editingDisabled
                cell.delegate = self;
                return cell
            } else { //Class Code
                let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
                
                let key = classCodeText ?? ""
                classCodeText = key
                cell.configure(title: "Class Code",
                               textFieldText: key,
                               textFieldPlaceholder: "Make the Class Code easy to type!")
                cell.editingDisabled = editingDisabled
                cell.delegate = self
                cell.characterLimited = true
                
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonTableViewCell", for: indexPath) as! ButtonTableViewCell
            
            cell.button.setTitle(section4[indexPath.row], for: UIControlState.normal)
            cell.button.tintColor = UIColor.red
            cell.delegate = self
            cell.editingDisabled = editingDisabled
            
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard (editingDisabled == false) else {return editingDisabled;}

        return false

    }
    
    /*
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            
        }
    }*/
    
    
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
    }
    
    
    //MARK: - TableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

        guard !editingDisabled else {return}
        if indexPath.section == 2 { //Days of the week
            
            if selectedDay[indexPath.row] {
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
                selectedDay[indexPath.row] = false;
            } else {
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
                selectedDay[indexPath.row] = true;
            }
        }
        
        if let prevI = prevIndexPath {
            if let prevPickerCell = tableView.cellForRow(at: prevI) as? PickerViewTableViewCell {
                if (prevIndexPath != indexPath && prevPickerCell.showsDetails) {
                    prevPickerCell.showsDetails = !prevPickerCell.showsDetails
                    
                    UIView.animate(withDuration: 0.3) {
                        prevPickerCell.contentView.layoutIfNeeded() // Or self.contentView if you're doing this from your own cell subclass
                    }
                }
            } else if let prevPickerCell = tableView.cellForRow(at: prevI) as? DatePickerViewTableViewCell {
                if (prevIndexPath != indexPath && prevPickerCell.showsDetails) {
                    prevPickerCell.showsDetails = !prevPickerCell.showsDetails
                    
                    UIView.animate(withDuration: 0.3) {
                        prevPickerCell.contentView.layoutIfNeeded() // Or self.contentView if you're doing this from your own cell subclass
                    }
                }
            }
        }
        
        if let pickerCell = tableView.cellForRow(at: indexPath) as? PickerViewTableViewCell {
            pickerCell.showsDetails = !pickerCell.showsDetails;
            
            
            UIView.animate(withDuration: 0.3) {
                pickerCell.contentView.layoutIfNeeded() // Or self.contentView if you're doing this from your own cell subclass
            }
            
            self.view.endEditing(true)
        } else if let pickerCell = tableView.cellForRow(at: indexPath) as? DatePickerViewTableViewCell {
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
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {

        }
    }
}

//MARK: - Extensions
extension AddClass2ViewController : SwitchTableViewCellDelegate {
    func switchCell(cell: UITableViewCell, isNowOn isOn: Bool) {
        shareSwitchIsOn = isOn
        self.tableView.reloadSections(IndexSet([3]), with: UITableViewRowAnimation.automatic)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        if let classCodeCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 3)) as? TextFieldTableViewCell {
            classCodeCell.becomeFirstResponder()
        }
    }
}

extension AddClass2ViewController : DatePickerViewTableCellDelegate {
    func datePickerCell(cell: UITableViewCell, selectedDate: Date) {
        if let indexPath = tableView.indexPath(for: cell) {
            if indexPath.section == 1 && indexPath.row == 2 { //Start Time
                classStartTime = selectedDate
            } else if indexPath.section == 1 && indexPath.row == 3 { //End Time
                classEndTime = selectedDate
            }
        }
    }

}

extension AddClass2ViewController : PickerViewTableCellDelegate {
    
    func pickerCell(cell: UITableViewCell, selectedPickerIndex index: Int, inArray array: [String]) {
        if let indexPath = tableView.indexPath(for: cell) {
            
            if indexPath.section == 0 && indexPath.row == 1 { //Color
                classColor = array[index]
                print("Changed color to \(classColor)")
            } 
        }
    }
}


extension AddClass2ViewController : TextFieldTableCellDelegate {
    func textFieldCell(cell: UITableViewCell, changedText text: String) {
        
        if let indexPath = tableView.indexPath(for: cell) {
            if indexPath.section == 0 && indexPath.row == 0 { //Class Name
                self.className = text
                print("New class name: " + text)
            } else if indexPath.section == 1 && indexPath.row == 0 { //Professor
                self.classProfessor = text
                print("New class professor: " + text)
            } else if indexPath.section == 1 && indexPath.row == 1 { //Location
                self.classLocation = text
                print("New class location: " + text)
            } else if indexPath.section == 3 && indexPath.row == 1 { //Class Code
                self.classCodeText = text
                print("New class code: " + text)
            }
        }
    }
    
    func textFieldCellBeganEditing(cell: UITableViewCell) {
        
        if let indexPath = tableView.indexPath(for: cell) {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
            self.tableView(tableView, didSelectRowAt: indexPath)
        }
    }
}

extension AddClass2ViewController : ButtonTableViewCellDelegate {
    func buttonPressed(_ button: UIButton, forCell cell: ButtonTableViewCell) {
        
        if let c = _class, let index = index, button.titleLabel?.text == "Delete Class" {
            
            let alert = UIAlertController(title: "Are you sure?", message: "This action is permanent. Any other users registered to this class will be affected.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("DELETE", comment: "Delete action"), style: UIAlertActionStyle.destructive, handler: { (action) in
                
                self.database.deleteClass(c, atIndex: index);
                
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

extension AddClass2ViewController : DatabaseManagerAddClassDelegate {
    func classCodeExists(_ classCode : String, exists: Bool) {
        //DONE - TODO: Present loading popup w/ cancel button
        if (exists) {
            //Create an alert saying that the class code is already being used.
            let alert = UIAlertController(title: "Class code already in use", message: "The class code is already being used. Please try modifying it.", preferredStyle: .alert)
            
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "OK action"), style: .default, handler: { (action) in

                if self.shareSwitchIsOn, let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 3)) as? TextFieldTableViewCell {
                    cell.textField.becomeFirstResponder()
                }
            }))
            
            self.present(alert, animated: true, completion: {
                print("Presented class code error")
            })
            
            
        } else {
            saveAndExit();
        }
 
    }
}

