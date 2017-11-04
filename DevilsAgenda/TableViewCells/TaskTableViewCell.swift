//
//  TaskTableViewCell.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/20/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    weak var task : Task?
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(task: Task) {
        // Configure the cell...
        self.task = task
        self.colorView.backgroundColor = Constants.uicolorForString(str: task.rClass.color)
        self.titleLabel.text = task.desc
        self.subtitleLabel.text = task.rClass.name
        
        var dateString = ""
        if let dueDate = task.dueDate {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US")
            //df.dateFormat = "E  M/d"
            df.dateFormat = "h:mm a"
            dateString = df.string(from: dueDate)
        }
        
        self.dateLabel.text = dateString
    }
    


}
