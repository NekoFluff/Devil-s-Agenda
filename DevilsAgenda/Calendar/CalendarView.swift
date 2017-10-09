//
//  CalendarView.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 10/1/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit
import SwiftDate

protocol CalendarViewDelegate {
    func selectedDate(_ date: Date)
}

class CalendarView: UIViewController {

    var date = Date()
    fileprivate var lastSelectedDate = Date()
    
    
    var delegate : CalendarViewDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            print("Cancel button pressed")
        }
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        
        self.delegate?.selectedDate(lastSelectedDate)
        
        self.dismiss(animated: true) {
            print("Done button pressed")
        }
    }
    
    enum Section: Int {
        case Month = 0, Week, Date
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.register(UINib.init(nibName: "MonthCell", bundle: nil), forCellWithReuseIdentifier: "MonthCell")
        collectionView.register(UINib.init(nibName: "WeekCell", bundle: nil), forCellWithReuseIdentifier: "WeekCell")
        collectionView.register(UINib.init(nibName: "DateCell", bundle: nil), forCellWithReuseIdentifier: "DateCell")
        
        setupDatePicker()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        selectDate(date)
    }
    
    
    
    //MARK: Private
    private func setupDatePicker() {
        datePicker.date = date
        self.datePicker.addTarget(self, action: #selector(dateTimeChanged(_:)), for: .valueChanged);
    }
    
    func dateTimeChanged(_ datePicker: UIDatePicker) {
        selectDate(datePicker.date)
    }
    
    func selectDate(_ selectedDate: Date) {
        lastSelectedDate = selectedDate
        
        if date.month != selectedDate.month {
            date = selectedDate
            collectionView.reloadSections(IndexSet([0,2]))
        }
        
        if let indexPath = indexPathForDate(selectedDate: selectedDate) {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.top)
            datePicker.setDate(selectedDate, animated: true)
        }
    }
    
    private func indexPathForDate(selectedDate: Date) -> IndexPath? {
        
        if date.month == selectedDate.month {
            let row = date.startOf(component: .month).weekday + selectedDate.day - 2
            return IndexPath(row: row, section: 2)
        }
        
        return nil

    }
    
    func dateForIndexPath(_ indexPath: IndexPath) -> Date? {
        if (indexPath.section == Section.Date.rawValue) {
            return date.startOf(component: .month).add(components: [.day : indexPath.row - date.startOf(component: .month).weekday + 1])
        }
        return nil
    }
    

}

//MARK: UICollectionViewDataSource Extension
extension CalendarView : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch Section(rawValue: section)! {
        case .Month:
            return 1
        case .Week:
            return 7
        case .Date:
            return 7 * 6
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch Section(rawValue: indexPath.section)! {
        case .Month:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthCell", for: indexPath)
            if let cell = cell as? MonthCell {
                cell.configure(month: CalendarViewHelper.Months[date.month-1], year: date.year)
                cell.delegate = self
            }
            
            return cell
            
        case .Week:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekCell", for: indexPath)
            if let cell = cell as? WeekCell {
                cell.configure(week: CalendarViewHelper.Weeks[indexPath.item])
            }
            
            return cell
            
        case .Date:
            let (day, inMonth) = dayInMonthForRow(row: indexPath.item)
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath)
            if let cell = cell as? DateCell {
                cell.configure(date: day, inCurrentMonth: inMonth)
            }
            return cell
            
        }
        
    }
    
    //MARK: Private
    private func dayInMonthForRow(row: Int) -> (Int, Bool) {
        var day = 0
        var inMonth = false
        
        
        if (row < date.startOf(component: .month).weekday - 1) { //Before the month
            day = dateForRow(row) + (1.months.from(date: date)?.monthDays)!
        } else if (row - date.startOf(component: .month).weekday < date.monthDays - 1){ //In the month
            day = dateForRow(row)
            inMonth = true;
        } else { //After the month
            day = dateForRow(row) - date.monthDays
        }
        return (day, inMonth)
        
    }
    
    private func dateForRow(_ row: Int) -> Int {
        return row - date.startOf(component: .month).weekday + 2
    }
    
}

extension CalendarView : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == Section.Date.rawValue {
            if let date = dateForIndexPath(indexPath) {
                print("Weekday: \(date.weekday)")
                
                let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                
                var components = calendar.dateComponents([.hour, .minute], from: datePicker.date)
                components.setValue(date.day, for: .day)
                components.setValue(date.month, for: .month)
                components.setValue(date.year, for: .year)
                
                let dateAndTime = calendar.date(from: components)!
                datePicker.setDate(dateAndTime, animated: true)
                lastSelectedDate = dateAndTime
                
            }
        }
    }
}

extension CalendarView : UICollectionViewDelegateFlowLayout {
    
    //Set sizes of cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.bounds.width
        
        switch Section(rawValue: indexPath.section)! {
        case .Month:
            return CGSize(width: width, height: 50)
        case .Week:
            return CGSize(width: width/7, height: 30)
        case .Date:
            return CGSize(width: width/7, height: 40)
        }
    }
    
}

extension CalendarView : MonthCellDelegate {
    func getPreviousMonthAndYear() {
        date = date.add(components: [.month : -1])
        collectionView.reloadSections(IndexSet([0,2]))
    }
    
    func getNextMonthAndYear() {
        date = date.add(components: [.month : 1])
        collectionView.reloadSections(IndexSet([0,2]))
    }
}
