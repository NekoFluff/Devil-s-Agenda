//
//  TextFieldTableViewCell.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/14/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit

protocol TextFieldTableCellDelegate {
    func textFieldCell(cell: UITableViewCell, changedText text: String);
    func textFieldCellBeganEditing(cell: UITableViewCell)
}

class TextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {

    var delegate : TextFieldTableCellDelegate?
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var textField: UITextField!
    var editingDisabled = false {
        didSet {
            textField.isEnabled = !editingDisabled
            if editingDisabled && textField.canResignFirstResponder {
                textField.resignFirstResponder()
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(title: String, textFieldText: String, textFieldPlaceholder: String) {
        self.title.text = title
        self.textField.placeholder = textFieldPlaceholder
        self.textField.text = textFieldText
    }
    
    //MARK: TextField Delegate Methods
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        delegate?.textFieldCellBeganEditing(cell: self)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldCell(cell: self, changedText: textField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
