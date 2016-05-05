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
import CoreLocation

@available(iOS 9.0, *)
class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, WCSessionDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var calendarView: FSCalendar!
    let firstDayOfOmer = KCSefiratHaomerCalculator.dateOfSixteenNissanForYearOfDate(NSDate())
    let locationManager = SefiraDay.sharedInstance.locationManager
    
    // Our WatchConnectivity Session for communicating with the watchOS app
    var watchSession : WCSession?
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        if let date = message["date"] as? NSDate {
            let selectedDates = NSUserDefaults.standardUserDefaults().arrayForKey("SelectedDates") as? [NSDate]
            if var dates = selectedDates {
                dates.append(getDateOnly(date))
                NSUserDefaults.standardUserDefaults().setObject(dates, forKey: "SelectedDates")
            } else {
                NSUserDefaults.standardUserDefaults().setObject([date], forKey: "SelectedDates")
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.calendarView.selectDate(date)
                let tabBarController = self.tabBarController
                let tabBarItem = tabBarController!.tabBar.items![1]
                tabBarItem.badgeValue = nil
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            }
        }
    }
    
    func selectAll() {
        let dateOnly = self.getDateOnly(self.firstDayOfOmer)
        if let location = SefiraDay.sharedInstance.lastRecordedCLLocation {
            let adjustedDate = SefiraDay.dateAdjustedForHebrewCalendar(location, date: NSDate())
            let range = self.daysBetween(dateOnly, dt2: SefiraDay.dateAdjustedForHebrewCalendar(location, date: adjustedDate))
            var dates: [NSDate] = []
            for n in 0..<range {
                let dayComponent = NSDateComponents()
                dayComponent.day = n
                let calendar = NSCalendar.currentCalendar()
                let adjustedDate = calendar.dateByAddingComponents(dayComponent, toDate: dateOnly, options: NSCalendarOptions(rawValue: 0))!
                
                dates.append(adjustedDate)
            }
            NSUserDefaults.standardUserDefaults().setObject(dates, forKey: "SelectedDates")
            dispatch_async(dispatch_get_main_queue()) {
                for date in dates {
                    self.calendarView.selectDate(date)
                }
                let tabBarController = self.tabBarController
                let tabBarItem = tabBarController!.tabBar.items![1]
                tabBarItem.badgeValue = nil
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            }
        } else {
            locationManager.delegate = self
            SefiraDay.sharedInstance.getLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = locations.last!.coordinate
        SefiraDay.sharedInstance.lastRecordedCLLocation = locValue
        locationManager.stopUpdatingLocation()
        self.selectAll()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        if let needData = message["need_data"] as? Bool {
            if needData {
                var date = NSDate()
                let dates = self.calendarView.selectedDates as! [NSDate]
                if let location = SefiraDay.sharedInstance.lastRecordedCLLocation {
                    let tzeis = SefiraDay.getTzeis(location)
                    if tzeis.timeIntervalSinceNow < 0 {
                        date = date.dateByAddingTimeInterval(60*60*12)
                    }
                }
                
                if dates.contains(self.getDateOnly(date)) {
                    replyHandler(["is_selected": true])
                } else {
                    replyHandler(["is_selected": false])
                }
            }
        }
        if let selectAll = message["select_all"] as? Bool {
            if selectAll {
                self.selectAll()
                replyHandler(["is_selected": true])
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

        self.calendarView.delegate = self
        self.calendarView.appearance.headerMinimumDissolvedAlpha = 0.0;
        self.calendarView.clipsToBounds = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.calendarView.titleSelectionColor = UIColor(rgba: "#0E386C")
        self.calendarView.subtitleSelectionColor = UIColor(rgba: "#0E386C")
        
        if let selectedDates = NSUserDefaults.standardUserDefaults().arrayForKey("SelectedDates") as? [NSDate] {
            for date in selectedDates {
                self.calendarView.selectDate(date)
            }
            if let location = SefiraDay.sharedInstance.lastRecordedCLLocation {
                let adjustedDate = SefiraDay.dateAdjustedForHebrewCalendar(location, date: NSDate())
                if !selectedDates.contains(adjustedDate) {
                    let tabBarController = self.tabBarController
                    let tabBarItem = tabBarController!.tabBar.items![1]
                    tabBarItem.badgeValue = nil
                    UIApplication.sharedApplication().applicationIconBadgeNumber = 0
                }
            }
        }
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
    
    func calendar(calendar: FSCalendar, shouldSelectDate date: NSDate) -> Bool {
        if let location = SefiraDay.sharedInstance.lastRecordedCLLocation {
            let adjustedDate = SefiraDay.dateAdjustedForHebrewCalendar(location, date: NSDate())
            if date.compare(adjustedDate) == .OrderedDescending {
                return false
            } else {
                return true
            }
        } else {
            return true
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
        if let location = SefiraDay.sharedInstance.lastRecordedCLLocation {
            let adjustedDate = SefiraDay.dateAdjustedForHebrewCalendar(location, date: NSDate())
            if date == self.getDateOnly(adjustedDate) {
                let tabBarController = self.tabBarController
                let tabBarItem = tabBarController!.tabBar.items![1]
                tabBarItem.badgeValue = nil
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            }
            
            if let session = watchSession {
                if session.reachable {
                    session.sendMessage(["message" : date], replyHandler: nil, errorHandler: nil)
                } else {
                    do {
                        try watchSession?.updateApplicationContext(
                            ["message" : date]
                        )
                    } catch let error as NSError {
                        NSLog("Updating the context failed: " + error.localizedDescription)
                    }
                }
            }
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
        
        if let location = SefiraDay.sharedInstance.lastRecordedCLLocation {
            let adjustedDate = SefiraDay.dateAdjustedForHebrewCalendar(location, date: NSDate())
            if date == self.getDateOnly(adjustedDate) {
                let tabBarController = self.tabBarController
                let tabBarItem = tabBarController!.tabBar.items![1]
                tabBarItem.badgeValue = "1"
                UIApplication.sharedApplication().applicationIconBadgeNumber = 1
            }
            
            if let session = watchSession {
                if session.reachable {
                    session.sendMessage(["deselect" : date], replyHandler: nil, errorHandler: nil)
                } else {
                    do {
                        try watchSession?.updateApplicationContext(
                            ["deselect" : date]
                        )
                    } catch let error as NSError {
                        NSLog("Updating the context failed: " + error.localizedDescription)
                    }
                }
            }
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

    
    func daysBetween(dt1: NSDate, dt2: NSDate) -> Int {
        let unitFlags = NSCalendarUnit.Day
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(unitFlags, fromDate: dt1, toDate: dt2, options: NSCalendarOptions(rawValue: 0))
        return components.day + 1
    }

}
