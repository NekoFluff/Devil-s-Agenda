//
//  DatePickerTableViewCell.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 10/1/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit

protocol DatePickerViewTableCellDelegate {
    func pickerCell(cell: UITableViewCell, selectedPickerIndex index: Int, inArray array: [String])
}

class DatePickerTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        datePicker.minimumDate = Date();
        datePicker.datePickerMode = UIDatePickerMode.dateAndTime
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
