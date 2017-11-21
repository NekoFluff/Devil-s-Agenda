//
//  ClassTableViewCell.swift
//  DevilsAgenda
//
//  Created by Alexander Nou on 10/17/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit

class ClassTableViewCell: UITableViewCell {
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var titleLabelCenterY: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(_ _class: Class) {
        // Configure the cell...
        self.colorView.backgroundColor = Constants.uicolorForString(str: _class.color)
        self.titleLabel.text = _class.name
        
        let subtitleText = _class.isShared ? (_class.databaseKey ?? "Error") : nil
        
        self.subtitleLabel.text = subtitleText
        
        //If it isn't shared, but it
        if (!_class.isShared) {
            titleLabelCenterY.priority = 999;
        } else {
            titleLabelCenterY.priority = 749;
        }
//        var dateString = ""
//        if let dueDate = task.dueDate {
//            let df = DateFormatter()
//            df.locale = Locale(identifier: "en_US")
//            df.dateFormat = "E  M/d"
//            dateString = df.string(from: dueDate)
//        }
        
        self.dateLabel.text = nil
    }
    
}
