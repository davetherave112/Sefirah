//
//  SefiraDayWatch.swift
//  Sefirah
//
//  Created by Josh Siegel on 4/28/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import Foundation
import CoreLocation
import KosherCocoa

class SefiraDayWatch: NSObject {
    static let sharedInstance = SefiraDayWatch()
    
    var sefiraDate: Int?
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    func getLocation() {
        // Ask for Authorisation from the User.
        //locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.requestLocation()
            
        }
    }
    
    func setAdjustedSefiraDay(location: CLLocationCoordinate2D) {
        let location = KCGeoLocation(latitude: location.latitude, andLongitude: location.longitude, andTimeZone: NSTimeZone.localTimeZone())
        
        let jewishCalendar = KCJewishCalendar(location: location)
        let sunset = jewishCalendar.sunset()
        
        self.sefiraDate = self.workingDateAdjustedForSunset(sunset)
        NSUserDefaults.standardUserDefaults().setInteger(self.sefiraDate!, forKey: "LastRecordedDay")
        
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