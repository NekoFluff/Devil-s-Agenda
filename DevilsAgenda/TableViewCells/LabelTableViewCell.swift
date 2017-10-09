//
//  LabelTableViewCell.swift
//  DevilsAgenda
//
//  Created by Alexander Nou on 10/7/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit

class LabelTableViewCell:  UITableViewCell, UITextFieldDelegate {
    
    var delegate : TextFieldTableCellDelegate?
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var label: UILabel!
    var editingDisabled = false
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(titleText: String, labelText: String) {
        self.title.text = titleText
        self.label.text = labelText
    }
}
