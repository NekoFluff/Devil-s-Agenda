//
//  DateCell.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 10/1/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit

@IBDesignable class DateCell: UICollectionViewCell {
    
    //MARK: Variables
    override var isSelected: Bool {
        didSet {
            selectedLayer.isHidden = !isSelected
        }
    }
    
    var inCurrentMonth: Bool = true {
        didSet {
            self.dateLabel.alpha = (inCurrentMonth == true) ? 1.0 : 0.3
        }
    }
    
    @IBOutlet weak var dateLabel: UILabel!
    var selectedLayer : CALayer!
    
    
    //MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        let borderWidth : CGFloat = 0
        let borderHeight : CGFloat = 0
        
        selectedLayer = CALayer()
        selectedLayer.isHidden = true
        selectedLayer.frame = CGRect(x: borderWidth/2, y: borderHeight/2, width: frame.width - borderWidth, height: frame.height - borderHeight)
        
        
        selectedLayer.backgroundColor = UIColor.red.cgColor
        selectedLayer.opacity = 0.35
        selectedLayer.cornerRadius = 2
        selectedLayer.masksToBounds = false
        
        //self.layer.addSublayer(selectedLayer)
        self.layer.insertSublayer(selectedLayer, at: 0)
    }
    

    //MARK: Public Methods
    func configure(date: Int, inCurrentMonth: Bool) {
        dateLabel.text = "\(date)"
        self.inCurrentMonth = inCurrentMonth
        
    }

    override func prepareForInterfaceBuilder() {
        selectedLayer.isHidden = false
    }
}
