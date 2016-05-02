//
//  CalendarViewController.swift
//  Sefirah
//
//  Created by Josh Siegel on 5/1/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import UIKit
import FSCalendar
import KosherCocoa

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {

    @IBOutlet weak var calendarView: FSCalendar!
    let firstDayOfOmer = KCSefiratHaomerCalculator.dateOfSixteenNissanForYearOfDate(NSDate())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectedDates = NSUserDefaults.standardUserDefaults().arrayForKey("SelectedDates") as? [NSDate] {
            for date in selectedDates {
                self.calendarView.selectDate(date)
            }
        }
        
        self.calendarView.delegate = self
        self.calendarView.appearance.headerMinimumDissolvedAlpha = 0.0;
        self.calendarView.clipsToBounds = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func changeCalendarType() {
        self.calendarView.identifier = NSCalendarIdentifierHebrew
    }
    

    func calendar(calendar: FSCalendar, subtitleForDate date: NSDate) -> String? {
        if KCSefiratHaomerCalculator.dayOfSefiraForDate(date) == 0 {
            return ""
        } else {
            return "\(KCSefiratHaomerCalculator.dayOfSefiraForDate(date))d"
        }
        
    }
    
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate) {
        let selectedDates = NSUserDefaults.standardUserDefaults().arrayForKey("SelectedDates") as? [NSDate]
        if var dates = selectedDates {
            if dates.contains(date) {
                let index = dates.indexOf(date)
                dates.removeAtIndex(index!)
            } else {
                dates.append(date)
            }
            NSUserDefaults.standardUserDefaults().setObject(dates, forKey: "SelectedDates")
        } else {
            NSUserDefaults.standardUserDefaults().setObject([date], forKey: "SelectedDates")
        }
        
    }
    
    
    func maximumDateForCalendar(calendar: FSCalendar) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let maxDate = calendar.dateByAddingDays(50, toDate: self.firstDayOfOmer)
        return maxDate
    }
    
    func minimumDateForCalendar(calendar: FSCalendar) -> NSDate {
        return self.firstDayOfOmer
    }
    

}
