//
//  TrackerInterfaceController.swift
//  Sefirah
//
//  Created by Josh Siegel on 5/1/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import KosherCocoa

class TrackerInterfaceController: WKInterfaceController, WCSessionDelegate, DataSourceChangedDelegate {

    @IBOutlet var countLabel: WKInterfaceLabel!
    @IBOutlet var countButton: WKInterfaceButton!
    var countSent: Bool = false
    
    @IBAction func countAllDaysThroughToday() {
        self.countSent = true
        WatchSessionManager.sharedManager.sendMessage(["SelectAll": true])
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "Counted")
        self.setCounted(true)
    }
    
    @IBAction func trackOmerDay() {
        self.countSent = true
        let adjustedDate = self.getAdjustedDateOnly(NSDate())
        WatchSessionManager.sharedManager.sendMessage(["SelectedDate": adjustedDate])
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "Counted")
        self.setCounted(true)
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        WatchSessionManager.sharedManager.addDataSourceChangedDelegate(self)
        //self.requestUpdatedData()
    
    }

    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        let counted = NSUserDefaults.standardUserDefaults().boolForKey("Counted")
        self.requestUpdatedData()
        
    }
    
    
    override func didAppear() {
        super.didAppear()
        
        let counted = NSUserDefaults.standardUserDefaults().boolForKey("Counted")
        self.setCounted(counted)
    }

    override func didDeactivate() {
        //WatchSessionManager.sharedManager.removeDataSourceChangedDelegate(self)
        
        super.didDeactivate()
    }
    
    func setCounted(counted: Bool) {
        if counted {
            dispatch_async(dispatch_get_main_queue()) {
                self.countButton.setHidden(true)
                self.countLabel.setText("Well Done! You've already counted today.")
            }
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.countButton.setHidden(false)
                self.countLabel.setText("Count before you forget!")
            }
        }
    }
    
    func requestUpdatedData() {
        WatchSessionManager.sharedManager.sendMessage(["NeedData": true], replyHandler: { response in
                if let isSelected = response["is_selected"] as? Bool {
                    if (isSelected != NSUserDefaults.standardUserDefaults().boolForKey("Counted")) {
                        if self.countSent == true {
                            self.setCounted(NSUserDefaults.standardUserDefaults().boolForKey("Counted"))
                            self.countSent = false
                        } else {
                            self.setCounted(isSelected)
                            NSUserDefaults.standardUserDefaults().setBool(isSelected, forKey: "Counted")
                        }
                    }
                }
            }, errorHandler:  { error in
                print(error)
        })
    }
    
    func getAdjustedDateOnly(date: NSDate) -> NSDate {
        let flags: NSCalendarUnit = [.Year, .Month, .Day]
        let components = NSCalendar.currentCalendar().components(flags, fromDate: date)
        var adjustedDateOnly = NSCalendar.currentCalendar().dateFromComponents(components)!
        if let location = SefiraDayWatch.sharedInstance.lastRecordedCLLocation {
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
    
    func dataSourceDidUpdate(dataSource: DataSource) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        switch dataSource.date {
        case .Selected(let date):
            let shouldSelect = (date == self.getAdjustedDateOnly(NSDate()))
            if shouldSelect {
                userDefaults.setBool(true, forKey: "Counted")
                self.setCounted(true)
            }
        case .Deselected(let date):
            let shouldDeselect = (date == self.getAdjustedDateOnly(NSDate()))
            if shouldDeselect {
                userDefaults.setBool(false, forKey: "Counted")
                self.setCounted(false)
            }
        case .Unknown:
            //TODO: handle error
            break
        }
    }
}
