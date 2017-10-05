//
//  WeekCell.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 10/1/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit

class WeekCell: UICollectionViewCell {
    
    @IBOutlet weak var weekLabel: UILabel!
    
    func configure(week: String) {
        weekLabel.text = week
    }
}
