//
//  MonthCell.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 10/1/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit

protocol MonthCellDelegate {
    func getPreviousMonthAndYear()
    func getNextMonthAndYear()
}

class MonthCell: UICollectionViewCell {
    
    var delegate : MonthCellDelegate?
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var beforeButton: UIButton!
    @IBOutlet weak var afterButton: UIButton!
    
    @IBAction func beforeButtonPressed(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.getPreviousMonthAndYear()
        }
        
    }
    @IBAction func afterActionPressed(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.getNextMonthAndYear()
        }
    }
    
    func configure(month: String, year: Int) {
        monthLabel.text = "\(month) \(year)"
        contentView.isUserInteractionEnabled = false;
    }
}
