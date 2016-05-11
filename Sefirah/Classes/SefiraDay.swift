//
//  SefiraDay.swift
//  Sefirah
//
//  Created by Josh Siegel on 4/28/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import Foundation
import CoreLocation
import KosherCocoa

class SefiraDay: NSObject, CLLocationManagerDelegate {
    static let sharedInstance = SefiraDay()
    
    let locationManager: CLLocationManager = CLLocationManager()
    var lastRecordedCLLocation: CLLocationCoordinate2D?
    

    func getLocation() -> Bool {
        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
                locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
                if #available(iOS 9.0, *) {
                    locationManager.requestLocation()
                } else {
                    locationManager.startUpdatingLocation()
                }
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func setAdjustedSefiraDay(location: CLLocationCoordinate2D) -> Int {
        let KClocation = KCGeoLocation(latitude: location.latitude, andLongitude: location.longitude, andTimeZone: NSTimeZone.localTimeZone())
        self.lastRecordedCLLocation = location
        let jewishCalendar = KCJewishCalendar(location: KClocation)
        let sunset = jewishCalendar.tzais()
        
        return self.workingDateAdjustedForSunset(sunset)
        
    }
    
    
    class func dateAdjustedForHebrewCalendar(location: CLLocationCoordinate2D, date: NSDate) -> NSDate {
        let location = KCGeoLocation(latitude: location.latitude, andLongitude: location.longitude, andTimeZone: NSTimeZone.localTimeZone())
        
        let flags: NSCalendarUnit = [.Year, .Month, .Day]
        let components = NSCalendar.currentCalendar().components(flags, fromDate: date)
        let dateOnly = NSCalendar.currentCalendar().dateFromComponents(components)
        var adjustedDate = dateOnly
        let jewishCalendar = KCJewishCalendar(location: location)
        let tzeis = jewishCalendar.tzais()
        
        let isAfterSunset = tzeis.timeIntervalSinceNow < 0
        
        if isAfterSunset {
            let dayComponent = NSDateComponents()
            dayComponent.day = 1
            let calendar = NSCalendar.currentCalendar()
            adjustedDate = calendar.dateByAddingComponents(dayComponent, toDate: dateOnly!, options: NSCalendarOptions(rawValue: 0))!
        }
        
        return adjustedDate!
    }
    
    class func getTzeis(location: CLLocationCoordinate2D) -> NSDate {
        let KClocation = KCGeoLocation(latitude: location.latitude, andLongitude: location.longitude, andTimeZone: NSTimeZone.localTimeZone())
        let jewishCalendar = KCJewishCalendar(location: KClocation)
        return jewishCalendar.tzais()
    }
    
    func workingDateAdjustedForSunset(sunset: NSDate) -> Int {
        
        let isAfterSunset = sunset.timeIntervalSinceNow < 0
        
        var sefiraCount: Int?
        if (isAfterSunset) {
            sefiraCount = KCSefiratHaomerCalculator.dayOfSefira() + 1
        } else {
            sefiraCount = KCSefiratHaomerCalculator.dayOfSefira()
        }
        
        return sefiraCount!
    }
}