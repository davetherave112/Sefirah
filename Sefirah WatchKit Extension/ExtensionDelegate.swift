//
//  ExtensionDelegate.swift
//  Sefirah WatchKit Extension
//
//  Created by Josh Siegel on 4/24/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import WatchKit
import WatchConnectivity
import KosherCocoa

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(activationState)
    }

    
    var omerCount = "--"

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        UserDefaults.standard.register(defaults: [
            "Language" : Languages.Hebrew.rawValue,
            "Nusach" : Nusach.Ashkenaz.rawValue,
            "Options" : [Options.Beracha.rawValue, Options.Harachaman.rawValue],
            "ScheduleTzeis": true,
        ])
    
        WatchSessionManager.sharedManager.startSession()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

}
