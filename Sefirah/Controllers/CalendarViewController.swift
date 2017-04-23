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
class CalendarViewController: UIViewController, DataSourceChangedDelegate, FSCalendarDataSource, FSCalendarDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var calendarView: FSCalendar!
    var firstDayOfOmer: NSDate!
    let locationManager = SefiraDay.sharedInstance.locationManager
    
    func dateOfSixteenNissanForYear(of: Date) -> NSDate {
        var hebrewCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.hebrew)
        var hebrewYearInDate = hebrewCalendar?.years(in: of)
        
        return NSDate(day: 16, month: 8, year: UInt(hebrewYearInDate!), andCalendar: hebrewCalendar! as Calendar!)
    }
    
    func messageWasReceived(_ dataSource: DataSource) {
        switch dataSource.date {
        case .selected(let date):
            self.selectDate(date)
        case .selectAll(let selectAll):
            if selectAll {
                self.selectAll()
            }
        case .unknown:
            //TODO: handle error
            break
        default:
            //TODO: handle error
            break
        }
    }
    
    func messageWasReceivedWithHandler(_ dataSource: DataSource, replyHandler: ([String : AnyObject]) -> Void) {
        switch dataSource.date {
        case .needData(let needData):
            if needData {
                let dates = self.calendarView.selectedDates as! [Date]
                let adjustedDate = self.getAdjustedDateOnly(Date())
                if dates.contains(adjustedDate) {
                    replyHandler(["is_selected": true as AnyObject])
                } else {
                    replyHandler(["is_selected": false as AnyObject])
                }
            }
        case .unknown:
            //TODO: handle error
            replyHandler(["is_selected": false as AnyObject])
            break
        default:
            //TODO: handle error
            replyHandler(["is_selected": false as AnyObject])
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = locations.last!.coordinate
        SefiraDay.sharedInstance.lastRecordedCLLocation = locValue
        locationManager.stopUpdatingLocation()
        self.selectAll()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.firstDayOfOmer = dateOfSixteenNissanForYear(of: Date())
        self.calendarView.delegate = self
        self.calendarView.appearance.headerMinimumDissolvedAlpha = 0.0;
        self.calendarView.clipsToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WatchSessionManager.sharedManager.addDataSourceChangedDelegate(self)
        
        self.calendarView.appearance.titleSelectionColor = UIColor(rgba: "#161543")
        self.calendarView.appearance.subtitleSelectionColor = UIColor(rgba: "#161543")
        
        if let selectedDates = UserDefaults.standard.array(forKey: "SelectedDates") as? [Date] {
            for date in selectedDates {
                if date < self.firstDayOfOmer as Date {
                    var updatedDates = selectedDates
                    let index = updatedDates.index(of: date)
                    updatedDates.remove(at: index!)
                    UserDefaults.standard.set(updatedDates, forKey: "SelectedDates")
                    continue
                }
                self.calendarView.select(date)
            }
            if let location = SefiraDay.sharedInstance.lastRecordedCLLocation {
                let adjustedDate = self.getAdjustedDateOnly(Date())
                let tabBarController = self.tabBarController
                let tabBarItem = tabBarController!.tabBar.items![1]
                if selectedDates.contains(adjustedDate) {
                    tabBarItem.badgeValue = nil
                    UIApplication.shared.applicationIconBadgeNumber = 0
                } else {
                    tabBarItem.badgeValue = "1"
                    UIApplication.shared.applicationIconBadgeNumber = 1
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //WatchSessionManager.sharedManager.removeDataSourceChangedDelegate(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func changeCalendarType() {
        self.calendarView.identifier = NSCalendar.Identifier.hebrew.rawValue
    }
    

    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        if KCSefiratHaomerCalculator.dayOfSefira(for: date) == 0 {
            return ""
        } else {
            return "\(KCSefiratHaomerCalculator.dayOfSefira(for: date))d"
        }
        
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date) -> Bool {
        if let location = SefiraDay.sharedInstance.lastRecordedCLLocation {
            let adjustedDate = SefiraDay.dateAdjustedForHebrewCalendar(location, date: Date())
            if (date.compare(adjustedDate) == .orderedDescending) || (date > (Calendar.current as NSCalendar).date(byAddingDays: 50, to: self.firstDayOfOmer as Date!)) {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        let selectedDates = UserDefaults.standard.array(forKey: "SelectedDates") as? [Date]
        if var dates = selectedDates {
            if !dates.contains(date) {
                dates.append(date)
                UserDefaults.standard.set(dates, forKey: "SelectedDates")
            }
        } else {
            UserDefaults.standard.set([date], forKey: "SelectedDates")
        }
        if SefiraDay.sharedInstance.lastRecordedCLLocation != nil {
            if date == self.getAdjustedDateOnly(Date()) {
                let tabBarController = self.tabBarController
                let tabBarItem = tabBarController!.tabBar.items![1]
                tabBarItem.badgeValue = nil
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            
            do {
                // passing data via WatchSessionManager's updateApplicationContext here!
                try WatchSessionManager.sharedManager.updateApplicationContext(["selected" : date as AnyObject])
            } catch {
                //TODO: handle error
            }
        } else {
            locationManager.delegate = self
            let success = SefiraDay.sharedInstance.getLocation()
            if !success {
                let alert = UIAlertController(title: "Error", message: "Unauthorized GPS Access. Please open Sefirah on your iPhone and tap on current location.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
        let selectedDates = UserDefaults.standard.array(forKey: "SelectedDates") as? [Date]
        if var dates = selectedDates {
            if dates.contains(date) {
                let index = dates.index(of: date)
                dates.remove(at: index!)
                UserDefaults.standard.set(dates, forKey: "SelectedDates")
            }
        }
        
        if SefiraDay.sharedInstance.lastRecordedCLLocation != nil {
            if date == self.getAdjustedDateOnly(Date()) {
                let tabBarController = self.tabBarController
                let tabBarItem = tabBarController!.tabBar.items![1]
                tabBarItem.badgeValue = "1"
                UIApplication.shared.applicationIconBadgeNumber = 1
            }
            
            do {
                // passing data via WatchSessionManager's updateApplicationContext here!
                try WatchSessionManager.sharedManager.updateApplicationContext(["deselected" : date as AnyObject])
            } catch {
                //TODO: handle error
            }
        } else {
            locationManager.delegate = self
            let success = SefiraDay.sharedInstance.getLocation()
            if !success {
                let alert = UIAlertController(title: "Error", message: "Unauthorized GPS Access. Please open Sefirah on your iPhone and tap on current location.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        let calendar = Calendar.current
        let maxDate = (calendar as NSCalendar).date(byAddingDays: 50, to: self.firstDayOfOmer as Date!)
        return maxDate! as Date
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        self.calendarView.setCurrentPage(self.firstDayOfOmer! as Date, animated: false)
        return self.firstDayOfOmer! as Date
    }
    
    func getAdjustedDateOnly(_ date: Date) -> Date {
        let flags: NSCalendar.Unit = [.year, .month, .day]
        let components = (Calendar.current as NSCalendar).components(flags, from: date)
        var adjustedDateOnly = Calendar.current.date(from: components)!
        if let location = SefiraDay.sharedInstance.lastRecordedCLLocation {
            if self.isAfterSunset(location, date: date) {
                var dayComponent = DateComponents()
                dayComponent.day = 1
                let calendar = Calendar.current
                let nextDate = (calendar as NSCalendar).date(byAdding: dayComponent, to: adjustedDateOnly, options: NSCalendar.Options(rawValue: 0))
                adjustedDateOnly = nextDate!
            }
        }
        return adjustedDateOnly
    }
    
    func isAfterSunset(_ location: CLLocationCoordinate2D, date: Date) -> Bool {
        let location = KCGeoLocation(latitude: location.latitude, andLongitude: location.longitude, andTimeZone: TimeZone.autoupdatingCurrent)
        
        let jewishCalendar = KCJewishCalendar(location: location)
        jewishCalendar?.workingDate = date
        let tzeis = jewishCalendar?.tzais()
        
        let isAfterSunset = tzeis!.timeIntervalSince(date) < 0
        
        return isAfterSunset
    }
    
    func daysBetween(_ dt1: Date, dt2: Date) -> Int {
        let unitFlags = NSCalendar.Unit.day
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(unitFlags, from: dt1, to: dt2, options: NSCalendar.Options(rawValue: 0))
        return components.day! + 1
    }
    
    func selectDate(_ date: Date) {
        var selectedDates = UserDefaults.standard.array(forKey: "SelectedDates") as? [Date]
        let adjustedDate = self.getAdjustedDateOnly(date)
        if selectedDates != nil {
            if !selectedDates!.contains(adjustedDate) {
                selectedDates!.append(adjustedDate)
                UserDefaults.standard.set(selectedDates!, forKey: "SelectedDates")
            }
        } else {
            UserDefaults.standard.set([date], forKey: "SelectedDates")
        }
        self.calendarView.select(date)
        let tabBarController = self.tabBarController
        let tabBarItem = tabBarController!.tabBar.items![1]
        tabBarItem.badgeValue = nil
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func selectAll() {
        let omerDate = self.firstDayOfOmer
        let flags: NSCalendar.Unit = [.year, .month, .day]
        let components = (Calendar.current as NSCalendar).components(flags, from: omerDate! as Date)
        let omerDateOnly = Calendar.current.date(from: components)!
        if SefiraDay.sharedInstance.lastRecordedCLLocation != nil {
            let adjustedDate = self.getAdjustedDateOnly(Date())
            let range = self.daysBetween(omerDateOnly, dt2: adjustedDate)
            var dates: [Date] = []
            for n in 0..<range {
                var dayComponent = DateComponents()
                dayComponent.day = n
                let calendar = Calendar.current
                let adjustedDate = (calendar as NSCalendar).date(byAdding: dayComponent, to: omerDateOnly, options: NSCalendar.Options(rawValue: 0))!
                if !dates.contains(adjustedDate) {
                    dates.append(adjustedDate)
                }
            }
            UserDefaults.standard.set(dates, forKey: "SelectedDates")
            for date in dates {
                self.calendarView.select(date)
            }
            let tabBarController = self.tabBarController
            let tabBarItem = tabBarController!.tabBar.items![1]
            tabBarItem.badgeValue = nil
            UIApplication.shared.applicationIconBadgeNumber = 0
        } else {
            locationManager.delegate = self
            let success = SefiraDay.sharedInstance.getLocation()
            if !success {
                let alert = UIAlertController(title: "Error", message: "Unauthorized GPS Access. Please open Sefirah on your iPhone and tap on current location.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

}
