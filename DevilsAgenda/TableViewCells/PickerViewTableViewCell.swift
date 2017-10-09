//
//  PickerViewTableViewCell.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/14/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit

protocol PickerViewTableCellDelegate {
    func pickerCell(cell: UITableViewCell, selectedPickerIndex index: Int, inArray array: [String])
}

class PickerViewTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource{

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    
    @IBOutlet weak var pickerHeight: NSLayoutConstraint!
    
    var delegate : PickerViewTableCellDelegate?
    var editingDisabled = false
    var pickerData = [""] {
        didSet {
            if pickerData.count > 0 {
                result.text = pickerData[0]
            } else {
                result.text = "Unknown"
            }
        }
    }
    
    var showsDetails = false {
        didSet {
            if !editingDisabled {
                pickerHeight.priority = showsDetails ? 250 : 999
                picker.isHidden = !showsDetails
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.pickerData = Array<String>()
        self.picker.delegate = self;
        self.picker.dataSource = self;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(title: String, data: [String], selectedRow: Int) {
        self.title.text = title
        self.pickerData = data
        self.result.text = data[selectedRow]
        self.picker.selectRow(selectedRow, inComponent: 0, animated: false)
    }
    
    //MARK: PickerView Delegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count // I get fatal error here due to pickerData is nil
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        result.text = pickerData[row]
        self.delegate?.pickerCell(cell: self, selectedPickerIndex: row, inArray: pickerData)
    }


}



