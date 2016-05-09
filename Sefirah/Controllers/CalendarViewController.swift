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
class CalendarViewController: UIViewController, DataSourceChangedDelegate, FSCalendarDataSource, FSCalendarDelegate, WCSessionDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var calendarView: FSCalendar!
    let firstDayOfOmer = KCSefiratHaomerCalculator.dateOfSixteenNissanForYearOfDate(NSDate())
    let locationManager = SefiraDay.sharedInstance.locationManager
    
    func messageWasReceived(dataSource: DataSource) {
        switch dataSource.date {
        case .Selected(let date):
            self.selectDate(date)
        case .SelectAll(let selectAll):
            if selectAll {
                self.selectAll()
            }
        case .Unknown:
            //TODO: handle error
            break
        default:
            //TODO: handle error
            break
        }
    }
    
    func messageWasReceivedWithHandler(dataSource: DataSource, replyHandler: ([String : AnyObject]) -> Void) {
        switch dataSource.date {
        case .NeedData(let needData):
            if needData {
                let dates = self.calendarView.selectedDates as! [NSDate]
                let adjustedDate = self.getAdjustedDateOnly(NSDate())
                if dates.contains(adjustedDate) {
                    replyHandler(["is_selected": true])
                } else {
                    replyHandler(["is_selected": false])
                }
            }
        case .Unknown:
            //TODO: handle error
            replyHandler(["is_selected": false])
            break
        default:
            //TODO: handle error
            replyHandler(["is_selected": false])
            break
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.calendarView.delegate = self
        self.calendarView.appearance.headerMinimumDissolvedAlpha = 0.0;
        self.calendarView.clipsToBounds = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        WatchSessionManager.sharedManager.addDataSourceChangedDelegate(self)
        
        self.calendarView.titleSelectionColor = UIColor(rgba: "#161543")
        self.calendarView.subtitleSelectionColor = UIColor(rgba: "#161543")
        
        if let selectedDates = NSUserDefaults.standardUserDefaults().arrayForKey("SelectedDates") as? [NSDate] {
            for date in selectedDates {
                self.calendarView.selectDate(date)
            }
            if let location = SefiraDay.sharedInstance.lastRecordedCLLocation {
                let adjustedDate = self.getAdjustedDateOnly(NSDate())
                let tabBarController = self.tabBarController
                let tabBarItem = tabBarController!.tabBar.items![1]
                if selectedDates.contains(adjustedDate) {
                    tabBarItem.badgeValue = nil
                    UIApplication.sharedApplication().applicationIconBadgeNumber = 0
                } else {
                    tabBarItem.badgeValue = "1"
                    UIApplication.sharedApplication().applicationIconBadgeNumber = 1
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        //WatchSessionManager.sharedManager.removeDataSourceChangedDelegate(self)
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
            if !dates.contains(date) {
                dates.append(date)
                NSUserDefaults.standardUserDefaults().setObject(dates, forKey: "SelectedDates")
            }
        } else {
            NSUserDefaults.standardUserDefaults().setObject([date], forKey: "SelectedDates")
        }
        if SefiraDay.sharedInstance.lastRecordedCLLocation != nil {
            if date == self.getAdjustedDateOnly(NSDate()) {
                let tabBarController = self.tabBarController
                let tabBarItem = tabBarController!.tabBar.items![1]
                tabBarItem.badgeValue = nil
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            }
            
            do {
                // passing data via WatchSessionManager's updateApplicationContext here!
                try WatchSessionManager.sharedManager.updateApplicationContext(["selected" : date])
            } catch {
                //TODO: handle error
            }
        } else {
            locationManager.delegate = self
            SefiraDay.sharedInstance.getLocation()
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
        
        if SefiraDay.sharedInstance.lastRecordedCLLocation != nil {
            if date == self.getAdjustedDateOnly(NSDate()) {
                let tabBarController = self.tabBarController
                let tabBarItem = tabBarController!.tabBar.items![1]
                tabBarItem.badgeValue = "1"
                UIApplication.sharedApplication().applicationIconBadgeNumber = 1
            }
            
            do {
                // passing data via WatchSessionManager's updateApplicationContext here!
                try WatchSessionManager.sharedManager.updateApplicationContext(["deselected" : date])
            } catch {
                //TODO: handle error
            }
        } else {
            locationManager.delegate = self
            SefiraDay.sharedInstance.getLocation()
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
    
    func getAdjustedDateOnly(date: NSDate) -> NSDate {
        let flags: NSCalendarUnit = [.Year, .Month, .Day]
        let components = NSCalendar.currentCalendar().components(flags, fromDate: date)
        var adjustedDateOnly = NSCalendar.currentCalendar().dateFromComponents(components)!
        if let location = SefiraDay.sharedInstance.lastRecordedCLLocation {
            if self.isAfterSunset(location, date: date) {
                let dayComponent = NSDateComponents()
                dayComponent.day = 1
                let calendar = NSCalendar.currentCalendar()
                let nextDate = calendar.dateByAddingComponents(dayComponent, toDate: adjustedDateOnly, options: NSCalendarOptions(rawValue: 0))
                adjustedDateOnly = nextDate!
            }
        }
        return adjustedDateOnly
    }
    
    func isAfterSunset(location: CLLocationCoordinate2D, date: NSDate) -> Bool {
        let location = KCGeoLocation(latitude: location.latitude, andLongitude: location.longitude, andTimeZone: NSTimeZone.localTimeZone())
        
        let jewishCalendar = KCJewishCalendar(location: location)
        jewishCalendar.workingDate = date
        let tzeis = jewishCalendar.tzais()
        
        let isAfterSunset = tzeis.timeIntervalSinceDate(date) < 0
        
        return isAfterSunset
    }
    
    func daysBetween(dt1: NSDate, dt2: NSDate) -> Int {
        let unitFlags = NSCalendarUnit.Day
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(unitFlags, fromDate: dt1, toDate: dt2, options: NSCalendarOptions(rawValue: 0))
        return components.day + 1
    }
    
    func selectDate(date: NSDate) {
        var selectedDates = NSUserDefaults.standardUserDefaults().arrayForKey("SelectedDates") as? [NSDate]
        let adjustedDate = self.getAdjustedDateOnly(date)
        if selectedDates != nil {
            if !selectedDates!.contains(adjustedDate) {
                selectedDates!.append(adjustedDate)
                NSUserDefaults.standardUserDefaults().setObject(selectedDates!, forKey: "SelectedDates")
            }
        } else {
            NSUserDefaults.standardUserDefaults().setObject([date], forKey: "SelectedDates")
        }
        self.calendarView.selectDate(date)
        let tabBarController = self.tabBarController
        let tabBarItem = tabBarController!.tabBar.items![1]
        tabBarItem.badgeValue = nil
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    func selectAll() {
        let omerDate = self.firstDayOfOmer
        let flags: NSCalendarUnit = [.Year, .Month, .Day]
        let components = NSCalendar.currentCalendar().components(flags, fromDate: omerDate)
        let omerDateOnly = NSCalendar.currentCalendar().dateFromComponents(components)!
        if SefiraDay.sharedInstance.lastRecordedCLLocation != nil {
            let adjustedDate = self.getAdjustedDateOnly(NSDate())
            let range = self.daysBetween(omerDateOnly, dt2: adjustedDate)
            var dates: [NSDate] = []
            for n in 0..<range {
                let dayComponent = NSDateComponents()
                dayComponent.day = n
                let calendar = NSCalendar.currentCalendar()
                let adjustedDate = calendar.dateByAddingComponents(dayComponent, toDate: omerDateOnly, options: NSCalendarOptions(rawValue: 0))!
                if !dates.contains(adjustedDate) {
                    dates.append(adjustedDate)
                }
            }
            NSUserDefaults.standardUserDefaults().setObject(dates, forKey: "SelectedDates")
            for date in dates {
                self.calendarView.selectDate(date)
            }
            let tabBarController = self.tabBarController
            let tabBarItem = tabBarController!.tabBar.items![1]
            tabBarItem.badgeValue = nil
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        } else {
            locationManager.delegate = self
            SefiraDay.sharedInstance.getLocation()
        }
    }

}
