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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class NotificationManager: NSObject, CLLocationManagerDelegate {
    lazy var db: CoreDataDefaultStorage = {
        let store = CoreDataStore.named("db")
        let bundle = Bundle(for: self.classForCoder)
        let model = CoreDataObjectModel.merged([bundle])
        let defaultStorage = try! CoreDataDefaultStorage(store: store, model: model)
        return defaultStorage
    }()
    
    static let sharedInstance = NotificationManager()
    let locationManager = CLLocationManager()

    func getNotificationsDictionary() -> [String: [Bool: Date]]? {
        let data = UserDefaults.standard.object(forKey: "Notifications")
        let object = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
        return object as? [String: [Bool: Date]]
    }
    
    func getAllNotifications() -> [UILocalNotification] {
        if let notifications = UIApplication.shared.scheduledLocalNotifications {
            return notifications
        } else {
            return []
        }
    }
    
    func getLocation() {
        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        //locationManager.requestWhenInUseAuthorization()
        
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = locations.last!.coordinate
        
        locationManager.stopUpdatingLocation()

        scheduleTzeis(locValue)

    }

    func scheduleTzeis(_ location: CLLocationCoordinate2D) {
        let settings = UIApplication.shared.currentUserNotificationSettings
        
        if settings!.types == UIUserNotificationType() {
            return
        }
        
        let timeZone = TimeZone.autoupdatingCurrent
        let location: KCGeoLocation = KCGeoLocation.init(latitude: location.latitude, andLongitude: location.longitude, andTimeZone: timeZone)
        let calendar: KCZmanimCalendar = KCZmanimCalendar.init(location: location)
        
        var tzeis = calendar.tzais()
        
        if tzeis?.timeIntervalSinceNow < 0 {
            let adjustedDate = calendar.workingDate.addingTimeInterval(60*60*12)
            calendar.workingDate = adjustedDate
            tzeis = calendar.tzais()
        }
        
        //UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        let savedValues = UserDefaults.standard.array(forKey: "Tzeis") as! [Double]
        for value in savedValues {
            let tzeisOption = Tzeis(rawValue: value)
            let notificationName = tzeisOption?.notificationName
            let notifications = UIApplication.shared.scheduledLocalNotifications
            let notificationExists = notifications?.filter({($0.userInfo!["name"] as! String) == notificationName})
            if notificationExists?.count > 0 {
                print("")
            } else {
                let fireDate = tzeis?.addingTimeInterval(Double(tzeisOption!.rawValue * 60))
                scheduleLocal(notificationName!, fireDate: fireDate!, repeatAlert: false, tzeis: true)
            }
        }
        
    }
    
    func scheduleLocal(_ name: String, fireDate: Date, repeatAlert: Bool, tzeis: Bool = false) {
        let notification = UILocalNotification()
        notification.fireDate = fireDate
        if repeatAlert {
            notification.repeatInterval = NSCalendar.Unit.day
        }
        notification.alertBody = "This is a reminder to count Sefirat Ha'omer tonight/today!"
        //notification.timeZone = NSTimeZone.localTimeZone()
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["name": name]
        
        
        
        if tzeis {
            UIApplication.shared.scheduleLocalNotification(notification)
        } else {
            Notification.createNotification(name, fireDate: fireDate, enabled: true, repeatAlert: repeatAlert) { success, error in
                if let error = error {
                    //TODO: handle error
                    return
                } else {
                    UIApplication.shared.scheduleLocalNotification(notification)
                }
            }
        }
        for notification in UIApplication.shared.scheduledLocalNotifications! {
            let timeFormatter = DateFormatter()
            timeFormatter.setLocalizedDateFormatFromTemplate("hh/mm a")
            let timeString: String = timeFormatter.string(from: notification.fireDate!)
            print(timeString)
        }
    }
}
