//
//  ScheduleCells.swift
//  DevilsAgenda
//
//  Created by Alexander Nou on 11/20/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import Foundation

/*
 
//
//  Cells.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/8/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import SpreadsheetView

class ScheduleDateCell: Cell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textAlignment = .center
        
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class DayTitleCell: Cell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class TimeTitleCell: Cell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class TimeCell: Cell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: UIFontWeightMedium)
        label.textAlignment = .right
        
        contentView.addSubview(label)
    }
    
    override var frame: CGRect {
        didSet {
            label.frame = bounds.insetBy(dx: 6, dy: 0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class ScheduleCell: Cell {
    let label = UILabel()
    var color: UIColor = .clear {
        didSet {
            backgroundView?.backgroundColor = color
        }
    }
    
    override var frame: CGRect {
        didSet {
            label.frame = bounds.insetBy(dx: 4, dy: 0)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundView = UIView()
        
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .left
        
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
 */

//
//  Cells.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/11/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import UIKit
import SpreadsheetView

class HourCell: Cell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.frame = bounds
        
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.backgroundColor = UIColor(red: 0.220, green: 0.471, blue: 0.871, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class ChannelCell: Cell {
    let label = UILabel()
    
    var channel = "" {
        didSet {
            label.text = String(channel)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.backgroundColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 2
        
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class SlotCell: Cell {
    @IBOutlet private weak var minutesLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableHighlightLabel: UILabel!
    
    var minutes = 0 {
        didSet {
            minutesLabel.text = String(format: "%02d", minutes)
        }
    }
    var title = "" {
        didSet {
            titleLabel.text = title
        }
    }
    var tableHighlight = "" {
        didSet {
            tableHighlightLabel.text = tableHighlight
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class BlankCell: Cell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.9, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
