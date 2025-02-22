//
//  AddClassViewController.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/13/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit
import FirebaseAuth

class AddClassViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var classTextField: UITextField!
    @IBOutlet weak var colorTextField: UITextField!
    @IBOutlet weak var classCodeTextField: UITextField!
    
    @IBOutlet weak var classCodeLabel: UILabel!
    
    var pickerView : UIPickerView!
    let database = DatabaseManager.defaultManager
    private var _class : Class?;
    private var index : Int?;
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil);
    }
    @IBOutlet weak var deleteClassButton: UIButton!
    @IBAction func deleteClass(_ sender: Any) {
        if let index = index {
            
            //Create an alert saying that the class code is already being used.
            let alert = UIAlertController(title: "Are you sure?", message: "This action cannot be undone. All data loss is permanent. If this class is shared, all users following it will no longer be able to use it.", preferredStyle: .alert)
            
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("DELETE", comment: "Delete action"), style: .destructive, handler: { (action) in
                self.classCodeTextField.becomeFirstResponder()
                self.database.deleteClass(self.database.classes[index], atIndex: index)
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel, handler: { (action) in
                
            }))
            
            self.present(alert, animated: true, completion: {
                print("Presented class code error")
            })
            
        }
    }
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBAction func done(_ sender: UIBarButtonItem) {
        
        if self.addButton.title == "Edit" {
            
            self.classTextField.isEnabled = true;
            self.colorTextField.isEnabled = true;
            self.shareSwitch.isEnabled = true;
            self.classCodeTextField.isEnabled = true;
            self.addButton.title = "Done";
            
        } else if self.addButton.title == "Done" {
            
            var canSave = false;
            
            //Trying to save with a different class code
            let hasDifferentClassCode = (classCodeTextField.text != _class?.databaseKey)
            
            //The class code is different and you are still tyring to save as a shared class
            if shareSwitch.isOn && hasDifferentClassCode {
                database.checkIfSharedClassExists(classCode: classCodeTextField.text!)
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
    
    //DONE - TODO: For some reason it's not being registered as a followed class?
    //DONE - TODO: Only perform deletion/additon if switching from shared to notshared.
    // OTHERWISE, simply updating the data values will do.
    //DONE - TODO: Warning that completion data will be lost if switchign from shared to not shared. Also warn about making users lose access to the shared class.
    
    
    func saveAndExit() {
        //Construct the new class
        let newClass = Class(name: classTextField.text ?? "", color: colorTextField.text ?? "", owner: Auth.auth().currentUser!.uid, professor: nil, location: nil, startTime : nil, endTime : nil, daysOfTheWeek: [], shared: shareSwitch.isOn)
        
        if (shareSwitch.isOn) {
            newClass.databaseKey = classCodeTextField.text
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

    @IBOutlet weak var shareSwitch: UISwitch!
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if sender.isOn {
            self.classCodeTextField.isHidden = false;
            self.classCodeLabel.isHidden = false;
        } else {
            self.classCodeTextField.isHidden = true;
            self.classCodeLabel.isHidden = true;
        }
        
    }
    var pickOption = ["Red", "Green", "Blue", "Orange", "Yellow", "Black"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Create a toolbar and add a done button
/*
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44));
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(changeColor(_:)))
        let flex = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.items = [flex, doneButton]
 */
        //doneButton.tintColor = UIColor.black;
        
        
        //Create picker view, set the delegate, and assign it as the colorTextField's input
        //pickerView = UIPickerView(frame: CGRect(x: 0, y: toolBar.frame.size.height, width: self.view.frame.width, height: 200))
        pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 216))
        pickerView.dataSource = self
        pickerView.delegate = self
        
        
        //Create the input view and add the subviews
        //let inputView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: toolBar.frame.size.height + pickerView.frame.size.height))
        let inputView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: pickerView.frame.size.height))
        inputView.backgroundColor = UIColor.clear;
        inputView.addSubview(pickerView)
        //inputView.addSubview(toolBar)
        
        
        //Finally add the input view
        colorTextField.inputView = inputView
        
        updateFields()
        
        database.addClassDelegate = self;
        classCodeTextField.delegate = self;
    }
    
    func setClass(_ c : Class, withIndex index : Int) {
        self._class = c
        self.index = index;
    }
    
    private func updateFields() {
        if let c = _class {
            
            //Update all the fields
            self.navigationItem.title = "Class Info"
            self.addButton.title = "Edit"
            self.classTextField.text = c.name;
            self.pickerView.selectRow(rowForColor(c.color), inComponent: 0, animated: false)
            self.colorTextField.text = c.color
            self.shareSwitch.setOn(c.isShared, animated: false)
            
            if c.isShared {
                self.classCodeTextField.text = c.databaseKey
            } else {
                self.classCodeTextField.isHidden = true;
                self.classCodeLabel.isHidden = true;
            }
            
            //Disable editing fields until user selects Edit button
            self.classTextField.isEnabled = false;
            self.colorTextField.isEnabled = false;
            self.shareSwitch.isEnabled = false;
            self.classCodeTextField.isEnabled = false;
            
            if c.owner != Auth.auth().currentUser!.uid {
                self.addButton.isEnabled = false;

            }
        } else {
            self.deleteClassButton.isHidden = true;
            self.classCodeTextField.isHidden = true;
            self.classCodeLabel.isHidden = true;
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
    
    func changeColor(_ sender : UIBarButtonItem) {
        colorTextField.text = pickOption[pickerView.selectedRow(inComponent: 0)]
        colorTextField.resignFirstResponder()
    }
   
    //[toolBar setBarStyle:UIBarStyleBlackOpaque];
    //(or)pickerView.inputAccessoryView = toolBar;
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        colorTextField.text = pickOption[row]
    }
    
}


extension AddClassViewController : DatabaseManagerAddClassDelegate {
    func classCodeExists(_ classCode : String, exists: Bool) {
        
        if (exists) {
            //Create an alert saying that the class code is already being used.
            let alert = UIAlertController(title: "Class code already in use", message: "The class code is already being used. Please try modifying it.", preferredStyle: .alert)
            
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "OK action"), style: .default, handler: { (action) in
                self.classCodeTextField.becomeFirstResponder()
            }))

            self.present(alert, animated: true, completion: {
                print("Presented class code error")
            })
            
            
        } else {
            saveAndExit();
        }
    }
}

extension AddClassViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let set = NSCharacterSet(charactersIn: "ABCDEFGHIJKLMONPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-").inverted
        return (string.rangeOfCharacter(from: set) == nil)
    }
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
}
