//
//  PickerViewTableViewCell.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/14/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit

protocol DatePickerViewTableCellDelegate {
    func datePickerCell(cell: UITableViewCell, selectedDate: Date)
}

class DatePickerViewTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var picker: UIDatePicker!
    
    @IBOutlet weak var pickerHeight: NSLayoutConstraint!
    
    var delegate : DatePickerViewTableCellDelegate?
    var editingDisabled = false
    var formatter : DateFormatter!
    
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
        self.picker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: UIControlEvents.valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(title: String, date: Date, formatter: DateFormatter) {
        self.title.text = title
        self.result.text = formatter.string(from: date)
        self.picker.setDate(date, animated: false)
        self.formatter = formatter
    }
    
    //MARK: PickerView Delegate Methods
    func handleDatePicker(sender: UIDatePicker) {
        self.delegate?.datePickerCell(cell: self, selectedDate: picker.date)
        self.result.text = formatter.string(from: picker.date)
    }
}



