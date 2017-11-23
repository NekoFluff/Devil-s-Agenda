//
//  ScheduleViewController.swift
//  DevilsAgenda
//
//  Created by Alexander Nou on 11/20/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//


import UIKit
import FirebaseAuth
import SpreadsheetView

class ScheduleViewController: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    
    var days : [taskSection] = []
    let database = DatabaseManager.defaultManager
    let taskOrganizer = TaskOrganizer.defaultOrganizer
    
    let numberOfRows = 24 * 60 + 1
    var slotInfo = [IndexPath : (Int, Int, Class)]()
    var scheduleRequiresUpdate = false;
    
    let hourFormatter = DateFormatter()
    let twelveHourFormatter = DateFormatter()
    let hour = Date().hour
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    //MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()

        let today = Date()
        for i in 0...6 {
            days.append(taskOrganizer.getTaskSectionForDate(today.add(components: [.day : i])))
        }
        
        database.classDelegateForSchedule = self
        
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
        
        spreadsheetView.register(HourCell.self, forCellWithReuseIdentifier: String(describing: HourCell.self))
        spreadsheetView.register(ChannelCell.self, forCellWithReuseIdentifier: String(describing: ChannelCell.self))
        spreadsheetView.register(UINib(nibName: String(describing: SlotCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: SlotCell.self))
        spreadsheetView.register(BlankCell.self, forCellWithReuseIdentifier: String(describing: BlankCell.self))
        
        spreadsheetView.backgroundColor = .black
        
        let hairline = 1 / UIScreen.main.scale
        spreadsheetView.intercellSpacing = CGSize(width: hairline, height: hairline)
        spreadsheetView.gridStyle = .solid(width: hairline, color: .lightGray)
        spreadsheetView.circularScrolling = CircularScrolling.Configuration.horizontally.rowHeaderStartsFirstColumn
        
        hourFormatter.calendar = Calendar(identifier: .gregorian)
        hourFormatter.locale = Locale(identifier: "en_US_POSIX")
        hourFormatter.dateFormat = "h\na"
        
        twelveHourFormatter.calendar = Calendar(identifier: .gregorian)
        twelveHourFormatter.locale = Locale(identifier: "en_US_POSIX")
        twelveHourFormatter.dateFormat = "H"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Schedule will appear")
        if (scheduleRequiresUpdate) {
            self.spreadsheetView.reloadData()
            scheduleRequiresUpdate = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        spreadsheetView.flashScrollIndicators()
    }
    
    // MARK: - DataSource
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return days.count + 1
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return numberOfRows
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if column == 0 { //Hours
            return 30
        }
        return 130//Slot width
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if row == 0 { //Hours
            return 44
        }
        return 1.75 //Slot height
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        var mergedCells = [CellRange]()
        slotInfo = [:]
        for row in 0..<24 { //24 hours (column 0)
            mergedCells.append(CellRange(from: (60 * row + 1, 0), to: (60 * (row + 1), 0)))
        }
        

        let sortedClasses = database.classes.filter { (c) -> Bool in
            return c.startTime != nil && c.endTime != nil && c.daysOfTheWeek != nil
        }.sorted { (c1, c2) -> Bool in
            return c1.minSinceHour(date: c1.startTime!, comparedToHour: hour) < c2.minSinceHour(date: c2.startTime!, comparedToHour: hour)
        }
        
        for (indx, _) in days.enumerated() {
            
            var minutes = 0;
            var startMin = 0;
            var endMin = 0;
            
            for c in sortedClasses {
                
                if indx < c.daysOfTheWeek!.count && c.daysOfTheWeek![indx] == true {
                
                    startMin = c.minSinceHour(date: c.startTime, comparedToHour: hour)
                    if (startMin < minutes) {startMin = minutes + 1};
                    endMin = c.minSinceHour(date: c.endTime, comparedToHour: hour)
                    if (endMin < minutes) {endMin = minutes + 1}
                    
                    if (endMin < startMin) {
                        endMin = 60*24-1
                    }
                    let duration = (endMin - startMin)
                    
                    print("startMin: \(startMin)")
                    print("endMin: \(endMin)")
                    print("duration: \(duration)")
                    print("minutes: \(minutes)")
                    print("-----------------")
                    if duration == 0 {continue}
                    
                    print("start: \(c.startTime!) end: \(c.endTime!)" )
                    print("-----------------")
                    
                    if (minutes < startMin) { //Fill empty slots with a blank cell
                        mergedCells.append(CellRange(from: (minutes + 1, indx + 1), to: (startMin, indx + 1)))
                    }
                    
                    let cellRange = CellRange(from: (startMin + 1, indx + 1), to: (endMin, indx + 1))
                    mergedCells.append(cellRange) //Class cell
                    slotInfo[IndexPath(row: cellRange.from.row, column: cellRange.from.column)] = (startMin, duration, c) //Slot cell information (info on the class)
                    
                    minutes = endMin
                } else {
                    print("\(c.name) : \(indx) : \(c.daysOfTheWeek![indx])")
                }
                
            }
            
            if (minutes + 1 < 60*24) {
                mergedCells.append(CellRange(from: (minutes + 1, indx + 1), to: (60*24, indx + 1))) //Fill empty slots with a blank cell
            }
        }
        return mergedCells
    }
    
    
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? { //sp
        if indexPath.column == 0 && indexPath.row == 0 {
            return nil
        }
        
        if indexPath.column == 0 && indexPath.row > 0 { // Hours
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HourCell.self), for: indexPath) as! HourCell
            cell.label.text = hourFormatter.string(from: twelveHourFormatter.date(from: "\(((indexPath.row - 1) / 60 + hour) % 24)")!)
            
            cell.gridlines.top = .solid(width: 1, color: .white)
            cell.gridlines.bottom = .solid(width: 1, color: .white)
            return cell
        }
        if indexPath.column > 0 && indexPath.row == 0 {  // Day
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ChannelCell.self), for: indexPath) as! ChannelCell
            cell.label.text = days[indexPath.column - 1].rawValue
            if indexPath.column == 1 {
                cell.label.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 197/255, blue: 85/255, alpha: 1)
                cell.label.textColor = UIColor(colorLiteralRed: 140/255, green: 29/255, blue: 64/255, alpha: 1)
            } else {
                cell.label.backgroundColor = .black
                cell.label.textColor = .lightGray
            }
            cell.gridlines.top = .solid(width: 1, color: .black)
            cell.gridlines.bottom = .solid(width: 1, color: .black)
            cell.gridlines.left = .solid(width: 1 / UIScreen.main.scale, color: UIColor(white: 0.3, alpha: 1))
            cell.gridlines.right = cell.gridlines.left
            return cell
        }
        
        if let (minutes, cellSize, c) = slotInfo[indexPath] { //Time Slots
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: SlotCell.self), for: indexPath) as! SlotCell
            cell.minutes = minutes % 60
            cell.title = c.name
            cell.tableHighlight = cellSize > 20 ? "\(c.professor ?? "")\n\(c.location ?? "")\n\(c.convertTimeToString(c.startTime!, format: "h:mm a")) - \(c.convertTimeToString(c.endTime!, format: "h:mm a"))" : ""
            return cell
        }
        return spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: BlankCell.self), for: indexPath)
    }
    
    /// Delegate
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        print("Selected: (row: \(indexPath.row), column: \(indexPath.column))")
    }
}

extension ScheduleViewController : DatabaseManagerClassDelegate {
    func addedClass(class: Class) {
        self.scheduleRequiresUpdate = true
    }
    
    func deletedClass(_ c: Class, atIndex index: Int) {
        self.scheduleRequiresUpdate = true
    }
    
    func addedSharedClass(code: String, newClass: Class?, customErrorMessage msg: String?) {
        self.scheduleRequiresUpdate = true
    }
    
    func reloadClass(index: Int) {
        self.scheduleRequiresUpdate = true
    }
    
    func signOut() {
        
    }
}
