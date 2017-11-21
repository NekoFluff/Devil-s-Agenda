//
//  LabelTableViewCell.swift
//  DevilsAgenda
//
//  Created by Alexander Nou on 10/7/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit

protocol SwitchTableViewCellDelegate {
    func switchCell(cell: UITableViewCell, isNowOn isOn: Bool);
}

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var cellSwitch: UISwitch!
    var delegate : SwitchTableViewCellDelegate?
    var editingDisabled = false
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        self.delegate?.switchCell(cell: self, isNowOn: sender.isOn)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(title: String, isOn: Bool) {
        self.title.text = title
        self.cellSwitch.isOn = isOn
    }
}
