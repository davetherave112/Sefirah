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
import WatchConnectivity

@available(iOS 9.0, *)
class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, WCSessionDelegate {

    @IBOutlet weak var calendarView: FSCalendar!
    let firstDayOfOmer = KCSefiratHaomerCalculator.dateOfSixteenNissanForYearOfDate(NSDate())
    
    // Our WatchConnectivity Session for communicating with the watchOS app
    var watchSession : WCSession?
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        if let date = message["date"] as? NSDate {
            self.calendarView.selectDate(date)
            let selectedDates = NSUserDefaults.standardUserDefaults().arrayForKey("SelectedDates") as? [NSDate]
            if var dates = selectedDates {
                dates.append(date)
                NSUserDefaults.standardUserDefaults().setObject(dates, forKey: "SelectedDates")
            } else {
                NSUserDefaults.standardUserDefaults().setObject([date], forKey: "SelectedDates")
            }
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        if let needData = message["need_data"] as? Bool {
            if needData {
                let dates = self.calendarView.selectedDates as! [NSDate]
                if dates.contains(NSDate()) {
                    replyHandler(["is_selected": true])
                } else {
                    replyHandler(["is_selected": false])
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(WCSession.isSupported()){
            watchSession = WCSession.defaultSession()
            watchSession!.delegate = self
            watchSession!.activateSession()
        }
        
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
            dates.append(date)
            NSUserDefaults.standardUserDefaults().setObject(dates, forKey: "SelectedDates")
        } else {
            NSUserDefaults.standardUserDefaults().setObject([date], forKey: "SelectedDates")
        }
        
        if date == self.getDateOnly(NSDate()) {
            let tabBarController = self.tabBarController
            let tabBarItem = tabBarController!.tabBar.items![1]
            tabBarItem.badgeValue = nil
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        }
        
        do {
            try watchSession?.updateApplicationContext(
                ["message" : date]
            )
        } catch let error as NSError {
            NSLog("Updating the context failed: " + error.localizedDescription)
        }
    }
    
    func calendar(calendar: FSCalendar, didDeselectDate date: NSDate) {
        let selectedDates = NSUserDefaults.standardUserDefaults().arrayForKey("SelectedDates") as? [NSDate]
        if var dates = selectedDates {
            if dates.contains(date) {
                let index = dates.indexOf(date)
                dates.removeAtIndex(index!)
                NSUserDefaults.standardUserDefaults().setObject(dates, forKey: "SelectedDates")
            }
        }
        
        if date == self.getDateOnly(NSDate()) {
            let tabBarController = self.tabBarController
            let tabBarItem = tabBarController!.tabBar.items![1]
            tabBarItem.badgeValue = "1"
            UIApplication.sharedApplication().applicationIconBadgeNumber = 1
        }
        
        do {
            try watchSession?.updateApplicationContext(
                ["deselect" : date]
            )
        } catch let error as NSError {
            NSLog("Updating the context failed: " + error.localizedDescription)
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
    
    func getDateOnly(date: NSDate) -> NSDate {
        let flags: NSCalendarUnit = [.Year, .Month, .Day]
        let components = NSCalendar.currentCalendar().components(flags, fromDate: date)
        let dateOnly = NSCalendar.currentCalendar().dateFromComponents(components)
        return dateOnly!
    }

}
