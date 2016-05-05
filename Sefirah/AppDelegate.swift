//
//  AppDelegate.swift
//  Sefirah
//
//  Created by Josh Siegel on 4/24/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import UIKit
import KosherCocoa
import CoreLocation
import CoreData
import WatchConnectivity

@available(iOS 9.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //TODO: check badge number updated according to Tzeis
    
    var window: UIWindow?

    /*
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
    }
    */

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Register the preference defaults early.
        NSUserDefaults.standardUserDefaults().registerDefaults([
            "Language" : Languages.Hebrew.rawValue,
            "Nusach" : Nusach.Ashkenaz.rawValue,
            "Options" : [Options.Beracha.rawValue, Options.Harachaman.rawValue],
            "Tzeis": [Tzeis.FifteenBefore.rawValue]
        ])
        
        /*
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
        }
        */
        
        UITabBar.appearance().tintColor = UIColor(rgba: "#C19F69")
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
        
        NotificationManager.sharedInstance.getLocation()
        
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if let selectedDates = NSUserDefaults.standardUserDefaults().arrayForKey("SelectedDates") as? [NSDate] {
            let date = NSDate()
            let flags: NSCalendarUnit = [.Year, .Month, .Day]
            let components = NSCalendar.currentCalendar().components(flags, fromDate: date)
            let dateOnly = NSCalendar.currentCalendar().dateFromComponents(components)
            let adjustedDate = SefiraDay.dateAdjustedForHebrewCalendar(SefiraDay.sharedInstance.lastRecordedCLLocation!, date: dateOnly!)
            if !selectedDates.contains(adjustedDate) {
                let tabBarItem = (self.window?.rootViewController as! MainTabBarViewController).tabBar.items![1]
                tabBarItem.badgeValue = "1"
                UIApplication.sharedApplication().applicationIconBadgeNumber = 1
            }
        } else {
            let tabBarItem = (self.window?.rootViewController as! MainTabBarViewController).tabBar.items![1]
            tabBarItem.badgeValue = "1"
            UIApplication.sharedApplication().applicationIconBadgeNumber = 1
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "uk.co.plymouthsoftware.core_data" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("db", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("sefirah.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

@available(iOS 9.0, *)
extension AppDelegate: WCSessionDelegate {
   /*
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        let selectedDates = NSUserDefaults.standardUserDefaults().arrayForKey("SelectedDates") as? [NSDate]
        if let date = message["date"] as? NSDate {
            if var dates = selectedDates {
                dates.append(date)
                NSUserDefaults.standardUserDefaults().setObject(dates, forKey: "SelectedDates")
            } else {
                NSUserDefaults.standardUserDefaults().setObject([date], forKey: "SelectedDates")
            }
            replyHandler(["dates": NSUserDefaults.standardUserDefaults().arrayForKey("SelectedDates")!])
        }
        if let needData = message["need_data"] as? Bool {
            if needData {
                if let dates = selectedDates {
                    replyHandler(["dates": dates])
                }
            }
        }
    }
    */
}

