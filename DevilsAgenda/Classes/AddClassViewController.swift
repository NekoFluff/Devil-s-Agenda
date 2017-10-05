//
//  AddClassViewController.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/13/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit

class AddClassViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var classTextField: UITextField!
    @IBOutlet weak var colorTextField: UITextField!
    var pickerView : UIPickerView!
    let database = DatabaseManager.defaultManager
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil);
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {        
        database.saveClass(Class(name: classTextField.text ?? "", color: colorTextField.text ?? ""))
        dismiss(animated: true, completion: nil);
    }
    
    var pickOption = ["Red", "Green", "Blue", "Orange", "Yellow", "Black"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Create a toolbar and add a done button
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44));
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(changeColor(_:)))
        let flex = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.items = [flex, doneButton]
        //doneButton.tintColor = UIColor.black;
        
        
        //Create picker view, set the delegate, and assign it as the colorTextField's input
        pickerView = UIPickerView(frame: CGRect(x: 0, y: toolBar.frame.size.height, width: self.view.frame.width, height: 200))
        pickerView.dataSource = self
        pickerView.delegate = self
        
        
        //Create the input view and add the subviews
        let inputView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: toolBar.frame.size.height + pickerView.frame.size.height))
        inputView.backgroundColor = UIColor.clear;
        inputView.addSubview(pickerView)
        inputView.addSubview(toolBar)
        
        
        //Finally add the input view
        colorTextField.inputView = inputView

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
