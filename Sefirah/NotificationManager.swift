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

// WIP - create native notifications
enum NativeNotifications: Int {
    case Tzeis = 0
    
    var description: String {
        switch self {
        case .Tzeis:
            return "Tzeis"
        }
    }
}

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
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        
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
        
        scheduleLocal("Tzeis", fireDate: tzeis, repeatAlert: true)
        
    }
    
    func scheduleLocal(name: String, fireDate: NSDate, repeatAlert: Bool) {
        let notification = UILocalNotification()
        notification.fireDate = fireDate
        if repeatAlert {
            notification.repeatInterval = NSCalendarUnit.Day
        }
        notification.alertBody = "This is a reminder to count Sefirat Ha'omer tonight/today!"
        notification.timeZone = NSTimeZone.localTimeZone()
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["name": name]
        
        Notification.createNotification(name, fireDate: fireDate, enabled: true, repeatAlert: repeatAlert) { success, error in
            
            if let error = error {
                //TODO: handle error
                return
            } else {
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
        }
        
        /*
        var notificationsDict = getNotificationsDictionary()
        if let dictionary = notificationsDict {
            for (notificationName,_) in dictionary {
                if notificationName == name {
                    return
                }
            }
            notificationsDict![name] = [true: fireDate]
            let keyedArch = NSKeyedArchiver.archivedDataWithRootObject(notificationsDict!)
            NSUserDefaults.standardUserDefaults().setObject(keyedArch, forKey: "Notifications")
        } else {
            let notificationsDict = [name: [true: fireDate]]
            let keyedArch = NSKeyedArchiver.archivedDataWithRootObject(notificationsDict)
            NSUserDefaults.standardUserDefaults().setObject(keyedArch, forKey: "Notifications")
        }
        */
    
    }
}