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
            if status == .authorizedAlways || status == .authorizedWhenInUse {
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
    
    func setAdjustedSefiraDay(_ location: CLLocationCoordinate2D) -> Int {
        let KClocation = KCGeoLocation(latitude: location.latitude, andLongitude: location.longitude, andTimeZone: TimeZone.autoupdatingCurrent)
        self.lastRecordedCLLocation = location
        let jewishCalendar = KCJewishCalendar(location: KClocation)
        let sunset = jewishCalendar?.tzais()
        
        return self.workingDateAdjustedForSunset(sunset!)
        
    }
    
    
    class func dateAdjustedForHebrewCalendar(_ location: CLLocationCoordinate2D, date: Date) -> Date {
        let location = KCGeoLocation(latitude: location.latitude, andLongitude: location.longitude, andTimeZone: TimeZone.autoupdatingCurrent)
        
        let flags: NSCalendar.Unit = [.year, .month, .day]
        let components = (Calendar.current as NSCalendar).components(flags, from: date)
        let dateOnly = Calendar.current.date(from: components)
        var adjustedDate = dateOnly
        let jewishCalendar = KCJewishCalendar(location: location)
        let tzeis = jewishCalendar?.tzais()
        
        let isAfterSunset = tzeis!.timeIntervalSinceNow < 0
        
        if isAfterSunset {
            var dayComponent = DateComponents()
            dayComponent.day = 1
            let calendar = Calendar.current
            adjustedDate = (calendar as NSCalendar).date(byAdding: dayComponent, to: dateOnly!, options: NSCalendar.Options(rawValue: 0))!
        }
        
        return adjustedDate!
    }
    
    class func getTzeis(_ location: CLLocationCoordinate2D) -> Date {
        let KClocation = KCGeoLocation(latitude: location.latitude, andLongitude: location.longitude, andTimeZone: TimeZone.autoupdatingCurrent)
        let jewishCalendar = KCJewishCalendar(location: KClocation)
        return jewishCalendar!.tzais()
    }
    
    func workingDateAdjustedForSunset(_ sunset: Date) -> Int {
        
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
