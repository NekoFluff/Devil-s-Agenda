//
//  ButtonTableViewCell.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/14/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit

protocol ButtonTableViewCellDelegate {
    func buttonPressed(_ button: UIButton, forCell cell: ButtonTableViewCell);
}

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    @IBAction func buttonPressed(_ sender: UIButton) {
        delegate?.buttonPressed(sender, forCell: self)
    }
    
    var delegate : ButtonTableViewCellDelegate? = nil
    
    var editingDisabled = false {
        didSet {
            self.button.isEnabled = !editingDisabled
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        button.isEnabled = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
