//
//  MonthCell.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 10/1/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit

class MonthCell: UICollectionViewCell {
    
    @IBOutlet weak var monthLabel: UILabel!
    
    func configure(month: String, year: Int) {
        monthLabel.text = "\(month) \(year)"
    }
}
