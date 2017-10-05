//
//  DateCell.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 10/1/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit

class DateCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    func configure(date: Int) {
        dateLabel.text = "\(date)"
    }
}
