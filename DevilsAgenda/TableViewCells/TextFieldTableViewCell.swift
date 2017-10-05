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
}

class TextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {

    var delegate : TextFieldTableCellDelegate?
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldCell(cell: self, changedText: textField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
