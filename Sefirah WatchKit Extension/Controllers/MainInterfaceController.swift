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
    var success: Bool?
    var alertDisplayed = false
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        
        adjustedDay.locationManager.delegate = self
        success = adjustedDay.getLocation()
        
    }
    
    

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.setProgress(true)
        
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = locations.last!.coordinate
        adjustedDay.locationManager.stopUpdatingLocation()
        adjustedDay.setAdjustedSefiraDay(locValue)
        if let dayOfSefira = adjustedDay.sefiraDate {
            self.setProgress(true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if UserDefaults.standard.integer(forKey: "LastRecordedDay") > 0 {
            let dayOfSefira = UserDefaults.standard.integer(forKey: "LastRecordedDay")
            if SefiraDayWatch.sharedInstance.sefiraDate == nil {
                SefiraDayWatch.sharedInstance.sefiraDate = dayOfSefira
                self.setProgress(true)
            }
        }
        print(error)
    }
    
    
    func setProgress(_ animate: Bool) {
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
                progressGroup.startAnimatingWithImages(in: range, duration: 0.7, repeatCount: 1)
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
                progressGroup.startAnimatingWithImages(in: range!, duration: 0.7, repeatCount: 1)
                self.timeLabel.setText("Remaining:" + timeString)
            }
            self.lastRemainingInterval = Int(length)
        } else {
            adjustedDay.getLocation()
            self.progressGroup.setBackgroundImageNamed("time0")
        }
        
        if let extensionDelegate = (WKExtension.shared().delegate as? ExtensionDelegate) {
            extensionDelegate.omerCount = String(describing: adjustedDay.sefiraDate)
        }
    }
    
    func timeInterval(_ location: CLLocationCoordinate2D) -> TimeInterval {
        let location = KCGeoLocation(latitude: location.latitude, andLongitude: location.longitude, andTimeZone: TimeZone.autoupdatingCurrent)
        
        let jewishCalendar = KCJewishCalendar(location: location)
        var tzeis = jewishCalendar?.tzais()
        let current = Date()
        
        if tzeis!.timeIntervalSinceNow < 0.0 {
            let adjustedDate = jewishCalendar?.workingDate.addingTimeInterval(60*60*12)
            jewishCalendar?.workingDate = adjustedDate
            tzeis = jewishCalendar?.tzais()
        }
        
        let difference = current.timeIntervalSince(tzeis!)
        
        return difference

    }
    
    func timeIntervalToString(_ interval: TimeInterval) -> String {
        var work = interval * -1
        let seconds = work.truncatingRemainder(dividingBy: 60)
        work /= 60
        let minutes = work.truncatingRemainder(dividingBy: 60)
        let hours = work / 60
        let timeString = String(format: "%0.2d:%0.2d", Int(hours), Int(minutes))
        
        return timeString
    }



}
