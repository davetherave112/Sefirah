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

class TrackerInterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var countLabel: WKInterfaceLabel!
    @IBOutlet var countButton: WKInterfaceButton!
    
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
    }
    
    
    func isAfterSunset(location: CLLocationCoordinate2D) -> Bool {
        let location = KCGeoLocation(latitude: location.latitude, andLongitude: location.longitude, andTimeZone: NSTimeZone.localTimeZone())
        
        let jewishCalendar = KCJewishCalendar(location: location)
        let tzeis = jewishCalendar.tzais()
        
        let isAfterSunset = tzeis.timeIntervalSinceNow < 0
        
        return isAfterSunset
    }
    
    @IBAction func trackOmerDay() {
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            if let sefiraDate = SefiraDayWatch.sharedInstance.sefiraDate {
                let date = NSDate()
                let flags: NSCalendarUnit = [.Year, .Month, .Day]
                let components = NSCalendar.currentCalendar().components(flags, fromDate: date)
                var dateOnly = NSCalendar.currentCalendar().dateFromComponents(components)
                if let location = SefiraDayWatch.sharedInstance.lastRecordedCLLocation {
                    if self.isAfterSunset(location) {
                        let dayComponent = NSDateComponents()
                        dayComponent.day = 1
                        let calendar = NSCalendar.currentCalendar()
                        let nextDate = calendar.dateByAddingComponents(dayComponent, toDate: dateOnly!, options: NSCalendarOptions(rawValue: 0))
                        dateOnly = nextDate
                    }
                }
                session!.sendMessage(["date": dateOnly!], replyHandler: nil, errorHandler: nil)
                self.countLabel.setText("Well Done! You've already counted today.")
                self.countButton.setHidden(true)
            } else {
                //TODO: handle error
            }
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        if let message : NSDate = message["message"] as? NSDate {
            let date = NSDate()
            let flags: NSCalendarUnit = [.Year, .Month, .Day]
            let components = NSCalendar.currentCalendar().components(flags, fromDate: date)
            var dateOnly = NSCalendar.currentCalendar().dateFromComponents(components)
            if let location = SefiraDayWatch.sharedInstance.lastRecordedCLLocation {
                if self.isAfterSunset(location) {
                    let dayComponent = NSDateComponents()
                    dayComponent.day = 1
                    let calendar = NSCalendar.currentCalendar()
                    let nextDate = calendar.dateByAddingComponents(dayComponent, toDate: dateOnly!, options: NSCalendarOptions(rawValue: 0))
                    dateOnly = nextDate
                }
            }
            if message == dateOnly {
                dispatch_async(dispatch_get_main_queue()) {
                    self.countButton.setHidden(true)
                    self.countLabel.setText("Well Done! You've already counted today.")
                }
            }
        }
        if let message : NSDate = message["deselect"] as? NSDate {
            let date = NSDate()
            let flags: NSCalendarUnit = [.Year, .Month, .Day]
            let components = NSCalendar.currentCalendar().components(flags, fromDate: date)
            var dateOnly = NSCalendar.currentCalendar().dateFromComponents(components)
            if let location = SefiraDayWatch.sharedInstance.lastRecordedCLLocation {
                if self.isAfterSunset(location) {
                    let dayComponent = NSDateComponents()
                    dayComponent.day = 1
                    let calendar = NSCalendar.currentCalendar()
                    let nextDate = calendar.dateByAddingComponents(dayComponent, toDate: dateOnly!, options: NSCalendarOptions(rawValue: 0))
                    dateOnly = nextDate
                }
            }
            if message == dateOnly {
                dispatch_async(dispatch_get_main_queue()) {
                    self.countButton.setHidden(false)
                    self.countLabel.setText("Count before you forget!")
                }
            }
        }

    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
    }

    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        session = WCSession.defaultSession()
        session!.sendMessage(["need_data": true], replyHandler: { response in
            if let isSelected = response["is_selected"] as? Bool {
                if isSelected {
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
        }, errorHandler: { error in
            print(error)
        })
    }
    
    override func didAppear() {
        super.didAppear()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
