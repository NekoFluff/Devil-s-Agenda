//
//  CalendarView.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 10/1/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit
import SwiftDate

class CalendarView: UIViewController {

    let date = Date()
    @IBOutlet weak var collectionView: UICollectionView!
    
    enum Section: Int {
        case Month = 0, Week, Date
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.register(UINib.init(nibName: "MonthCell", bundle: nil), forCellWithReuseIdentifier: "MonthCell")
        collectionView.register(UINib.init(nibName: "WeekCell", bundle: nil), forCellWithReuseIdentifier: "WeekCell")
        collectionView.register(UINib.init(nibName: "DateCell", bundle: nil), forCellWithReuseIdentifier: "DateCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}

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
            }
            return cell
        case .Week:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekCell", for: indexPath)
            if let cell = cell as? WeekCell {
                cell.configure(week: CalendarViewHelper.Weeks[indexPath.item])
            }
            return cell
        case .Date:
            
            int (day, inMonth) = dayInMonthForIndexPath(indexPath.item)
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath)
            if let cell = cell as? DateCell {
                cell.configure(date: 1)
            }
            return cell
        }
        
        
        
    }
    
    //MARK: Private
    private func dayInMonthForIndexPath(item: Int) -> (Int, Bool) {
        var day = 0
        var inMonth = false
        
        
        
        return (day, inMonth)
        
    }
    
    private func dayForItem() {
        
    }
    
}

extension CalendarView : UICollectionViewDelegate {
    
}

extension CalendarView : UICollectionViewDelegateFlowLayout {
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
