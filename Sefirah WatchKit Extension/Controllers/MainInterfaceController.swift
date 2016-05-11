//
//  InterfaceController.swift
//  Sefirah WatchKit Extension
//
//  Created by Josh Siegel on 4/24/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import WatchKit
import Foundation
import KosherCocoa
import CoreLocation

class MainInterfaceController: WKInterfaceController, CLLocationManagerDelegate {
    
    //TODO: Add last recorded day to NSUserDefaults for use case when no location services available
    
    @IBOutlet var timeLabel: WKInterfaceLabel!
    @IBOutlet var progressGroup: WKInterfaceGroup!
    let adjustedDay = SefiraDayWatch.sharedInstance
    @IBOutlet var progressImage: WKInterfaceImage!
    var imageDisplayed: Bool = false
    var lastRemainingInterval: Int?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        
        adjustedDay.locationManager.delegate = self
        let success = adjustedDay.getLocation()
        if !success {
            self.showPopup()
        }
        
    }
    
    func showPopup(){
        
        let h0 = { print("ok")}
        
        //let action1 = WKAlertAction(title: "Approve", style: .Default, handler:h0)
        //let action2 = WKAlertAction(title: "Decline", style: .Destructive) {}
        let action3 = WKAlertAction(title: "Cancel", style: .Cancel) {}
        
        presentAlertControllerWithTitle("Error", message: "Unauthorized GPS Access. Please open Sefirah on your iPhone and tap on current location.", preferredStyle: .ActionSheet, actions: [action3])
        
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.setProgress(adjustedDay.sefiraDate, animate: true)
        let success = adjustedDay.getLocation()
        if !success {
            self.showPopup()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = locations.last!.coordinate
        adjustedDay.locationManager.stopUpdatingLocation()
        adjustedDay.setAdjustedSefiraDay(locValue)
        if let dayOfSefira = adjustedDay.sefiraDate {
            self.setProgress(dayOfSefira, animate: true)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        if NSUserDefaults.standardUserDefaults().integerForKey("LastRecordedDay") > 0 {
            let dayOfSefira = NSUserDefaults.standardUserDefaults().integerForKey("LastRecordedDay")
            if SefiraDayWatch.sharedInstance.sefiraDate == nil {
                SefiraDayWatch.sharedInstance.sefiraDate = dayOfSefira
                self.setProgress(dayOfSefira, animate: true)
            }
        }
        print(error)
    }
    
    
    func setProgress(dayOfSefira: Int?, animate: Bool) {
        if let location = SefiraDayWatch.sharedInstance.lastRecordedCLLocation {
            let interval = self.timeInterval(location)
            let seconds = Double(interval * -1)
            let rangeInMinutes = (24.0 * 60.0)
            let remainginRangeInMinutes = rangeInMinutes - (seconds / 60)
            let length = round((remainginRangeInMinutes/rangeInMinutes) * 144.0)
            let timeString = self.timeIntervalToString(interval)
            if animate && !imageDisplayed {
                let range = NSRange.init(location: 0, length: Int(length))
                self.progressGroup.setBackgroundImageNamed("time")
                progressGroup.startAnimatingWithImagesInRange(range, duration: 0.7, repeatCount: 1)
                self.timeLabel.setText("Remaining:" + timeString)
                self.imageDisplayed = true
            } else if !animate && !imageDisplayed {
                self.progressGroup.setBackgroundImageNamed("time\(Int(length))")
                self.timeLabel.setText("Remaining:" + timeString)
                self.imageDisplayed = true
            } else {
                var range: NSRange?
                if let interval = self.lastRemainingInterval {
                    if interval == Int(length) {
                        self.timeLabel.setText("Remaining:" + timeString)
                        return
                    } else {
                        range = NSRange.init(location: interval, length: (Int(length) - interval))
                    }
                } else {
                    range = NSRange.init(location: 0, length: Int(length))
                }
                self.progressGroup.setBackgroundImageNamed("time")
                progressGroup.startAnimatingWithImagesInRange(range!, duration: 0.7, repeatCount: 1)
                self.timeLabel.setText("Remaining:" + timeString)
            }
            self.lastRemainingInterval = Int(length)
        } else {
            let success = adjustedDay.getLocation()
            if !success {
                self.showPopup()
            }
            self.progressGroup.setBackgroundImageNamed("time0")
        }
        
        if let extensionDelegate = (WKExtension.sharedExtension().delegate as? ExtensionDelegate) {
            extensionDelegate.omerCount = String(dayOfSefira)
        }
    }
    
    func timeInterval(location: CLLocationCoordinate2D) -> NSTimeInterval {
        let location = KCGeoLocation(latitude: location.latitude, andLongitude: location.longitude, andTimeZone: NSTimeZone.localTimeZone())
        
        let jewishCalendar = KCJewishCalendar(location: location)
        var tzeis = jewishCalendar.tzais()
        let current = NSDate()
        
        if tzeis.timeIntervalSinceNow < 0 {
            let adjustedDate = jewishCalendar.workingDate.dateByAddingTimeInterval(60*60*12)
            jewishCalendar.workingDate = adjustedDate
            tzeis = jewishCalendar.tzais()
        }
        
        let difference = current.timeIntervalSinceDate(tzeis)
        
        return difference

    }
    
    func timeIntervalToString(interval: NSTimeInterval) -> String {
        var work = interval * -1
        let seconds = work % 60
        work /= 60
        let minutes = work % 60
        let hours = work / 60
        let timeString = String(format: "%0.2d:%0.2d", Int(hours), Int(minutes))
        
        return timeString
    }



}
