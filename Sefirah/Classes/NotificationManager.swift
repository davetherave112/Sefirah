//
//  NotificationManager.swift
//  Sefirah
//
//  Created by Josh Siegel on 4/26/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import KosherCocoa
import CoreData
import SugarRecord

class NotificationManager: NSObject, CLLocationManagerDelegate {
    lazy var db: CoreDataDefaultStorage = {
        let store = CoreData.Store.Named("db")
        let bundle = NSBundle(forClass: self.classForCoder)
        let model = CoreData.ObjectModel.Merged([bundle])
        let defaultStorage = try! CoreDataDefaultStorage(store: store, model: model)
        return defaultStorage
    }()
    
    static let sharedInstance = NotificationManager()
    let locationManager = CLLocationManager()

    func getNotificationsDictionary() -> [String: [Bool: NSDate]]? {
        let data = NSUserDefaults.standardUserDefaults().objectForKey("Notifications")
        let object = NSKeyedUnarchiver.unarchiveObjectWithData(data as! NSData)
        return object as? [String: [Bool: NSDate]]
    }
    
    func getAllNotifications() -> [UILocalNotification] {
        if let notifications = UIApplication.sharedApplication().scheduledLocalNotifications {
            return notifications
        } else {
            return []
        }
    }
    
    func getLocation() {
        // Ask for Authorisation from the User.
        //locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            if #available(iOS 9.0, *) {
                locationManager.allowsBackgroundLocationUpdates = true
            } else {
                // Fallback on earlier versions
            }
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            if #available(iOS 9.0, *) {
                locationManager.requestLocation()
            } else {
                locationManager.startUpdatingLocation()
            }
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = locations.last!.coordinate
        
        locationManager.stopUpdatingLocation()

        scheduleTzeis(locValue)

    }

    func scheduleTzeis(location: CLLocationCoordinate2D) {
        let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        if settings!.types == .None {
            return
        }
        
        let timeZone = NSTimeZone.localTimeZone()
        let location: KCGeoLocation = KCGeoLocation.init(latitude: location.latitude, andLongitude: location.longitude, andTimeZone: timeZone)
        
        let calendar: KCZmanimCalendar = KCZmanimCalendar.init(location: location)
        let tzeis = calendar.tzais()
        
        
        let savedValues = NSUserDefaults.standardUserDefaults().arrayForKey("Tzeis") as! [Int]
        for value in savedValues {
            let tzeisOption = Tzeis(rawValue: value)
            let notificationName = tzeisOption?.notificationName
            let notifications = UIApplication.sharedApplication().scheduledLocalNotifications
            let notificationExists = notifications?.filter({($0.userInfo!["name"] as! String) == notificationName})
            if notificationExists?.count > 0 {
                print("notification exists")
            } else {
                let fireDate = tzeis.dateByAddingTimeInterval(Double(tzeisOption!.rawValue))
                scheduleLocal(notificationName!, fireDate: fireDate, repeatAlert: false, tzeis: true)
            }
        }
        
    }
    
    func scheduleLocal(name: String, fireDate: NSDate, repeatAlert: Bool, tzeis: Bool = false) {
        let notification = UILocalNotification()
        notification.fireDate = fireDate
        if repeatAlert {
            notification.repeatInterval = NSCalendarUnit.Day
        }
        notification.alertBody = "This is a reminder to count Sefirat Ha'omer tonight/today!"
        notification.timeZone = NSTimeZone.localTimeZone()
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["name": name]
        
        
        
        if tzeis {
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        } else {
            Notification.createNotification(name, fireDate: fireDate, enabled: true, repeatAlert: repeatAlert) { success, error in
                
                if let error = error {
                    //TODO: handle error
                    return
                } else {
                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
                }
            }
        }
    }
}