//
//  TrackerInterfaceController.swift
//  Sefirah
//
//  Created by Josh Siegel on 5/1/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import KosherCocoa

class TrackerInterfaceController: WKInterfaceController, WCSessionDelegate, DataSourceChangedDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(activationState)
    }


    @IBOutlet var countLabel: WKInterfaceLabel!
    @IBOutlet var countButton: WKInterfaceButton!
    var countSent: Bool = false
    
    @IBAction func countAllDaysThroughToday() {
        self.countSent = true
        WatchSessionManager.sharedManager.sendMessage(["SelectAll": true as AnyObject])
        UserDefaults.standard.set(true, forKey: "Counted")
        self.setCounted(true)
    }
    
    @IBAction func trackOmerDay() {
        self.countSent = true
        let adjustedDate = self.getAdjustedDateOnly(Date())
        WatchSessionManager.sharedManager.sendMessage(["SelectedDate": adjustedDate as AnyObject])
        UserDefaults.standard.set(true, forKey: "Counted")
        self.setCounted(true)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        WatchSessionManager.sharedManager.addDataSourceChangedDelegate(self)
        //self.requestUpdatedData()
    
    }

    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        let counted = UserDefaults.standard.bool(forKey: "Counted")
        self.requestUpdatedData()
        
    }
    
    
    override func didAppear() {
        super.didAppear()
        
        let counted = UserDefaults.standard.bool(forKey: "Counted")
        self.setCounted(counted)
    }

    override func didDeactivate() {
        //WatchSessionManager.sharedManager.removeDataSourceChangedDelegate(self)
        
        super.didDeactivate()
    }
    
    func setCounted(_ counted: Bool) {
        if counted {
            DispatchQueue.main.async {
                self.countButton.setHidden(true)
                self.countLabel.setText("Well Done! You've already counted today.")
            }
        } else {
            DispatchQueue.main.async {
                self.countButton.setHidden(false)
                self.countLabel.setText("Count before you forget!")
            }
        }
    }
    
    func requestUpdatedData() {
        WatchSessionManager.sharedManager.sendMessage(["NeedData": true as AnyObject], replyHandler: { response in
                if let isSelected = response["is_selected"] as? Bool {
                    if (isSelected != UserDefaults.standard.bool(forKey: "Counted")) {
                        if self.countSent == true {
                            self.setCounted(UserDefaults.standard.bool(forKey: "Counted"))
                            self.countSent = false
                        } else {
                            self.setCounted(isSelected)
                            UserDefaults.standard.set(isSelected, forKey: "Counted")
                        }
                    }
                }
            }, errorHandler:  { error in
                print(error)
        })
    }
    
    func getAdjustedDateOnly(_ date: Date) -> Date {
        let flags: NSCalendar.Unit = [.year, .month, .day]
        let components = (Calendar.current as NSCalendar).components(flags, from: date)
        var adjustedDateOnly = Calendar.current.date(from: components)!
        if let location = SefiraDayWatch.sharedInstance.lastRecordedCLLocation {
            if self.isAfterSunset(location, date: date) {
                var dayComponent = DateComponents()
                dayComponent.day = 1
                let calendar = Calendar.current
                let nextDate = (calendar as NSCalendar).date(byAdding: dayComponent, to: adjustedDateOnly, options: NSCalendar.Options(rawValue: 0))
                adjustedDateOnly = nextDate!
            }
        }
        return adjustedDateOnly
    }
    
    func isAfterSunset(_ location: CLLocationCoordinate2D, date: Date) -> Bool {
        let location = KCGeoLocation(latitude: location.latitude, andLongitude: location.longitude, andTimeZone: TimeZone.autoupdatingCurrent)
        
        let jewishCalendar = KCJewishCalendar(location: location)
        jewishCalendar?.workingDate = date
        let tzeis = jewishCalendar?.tzais()
        
        let isAfterSunset = tzeis!.timeIntervalSince(date) < 0
        
        return isAfterSunset
    }
    
    func dataSourceDidUpdate(_ dataSource: DataSource) {
        let userDefaults = UserDefaults.standard
        switch dataSource.date {
        case .selected(let date):
            let shouldSelect = (date == self.getAdjustedDateOnly(Date()))
            if shouldSelect {
                userDefaults.set(true, forKey: "Counted")
                self.setCounted(true)
            }
        case .deselected(let date):
            let shouldDeselect = (date == self.getAdjustedDateOnly(Date()))
            if shouldDeselect {
                userDefaults.set(false, forKey: "Counted")
                self.setCounted(false)
            }
        case .unknown:
            //TODO: handle error
            break
        }
    }
}
