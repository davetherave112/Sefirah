//
//  MainTabBarViewController.swift
//  Sefirah
//
//  Created by Josh Siegel on 5/1/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setStatusBarColor(UIColor(rgba: "#161543"))
        // Do any additional setup after loading the view.
        if let selectedDates = NSUserDefaults.standardUserDefaults().arrayForKey("SelectedDates") as? [NSDate] {
            if let location = SefiraDay.sharedInstance.lastRecordedCLLocation {
                let adjustedDate = SefiraDay.dateAdjustedForHebrewCalendar(location, date: NSDate())
                if !selectedDates.contains(adjustedDate) {
                    let tabBarItem = self.tabBar.items![1]
                    tabBarItem.badgeValue = "1"
                    UIApplication.sharedApplication().applicationIconBadgeNumber = 1
                }
            }
        } else {
            let tabBarItem = self.tabBar.items![1]
            tabBarItem.badgeValue = "1"
            UIApplication.sharedApplication().applicationIconBadgeNumber = 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if item.tag == 0 {
            self.setStatusBarColor(UIColor(rgba: "#161543"))
        } else if item.tag == 1 {
            self.setStatusBarColor(UIColor(rgba: "#ab8454"))
        } else if item.tag == 2 {
            self.setStatusBarColor(UIColor(rgba: "#ab8454"))
        }
    }
    
    func setStatusBarColor(color: UIColor) {
        let statusBarWindow = UIApplication.sharedApplication().valueForKey("statusBarWindow")
        let statusBar = statusBarWindow!.valueForKey("statusBar")
        let selector = Selector("setForegroundColor:")
        if statusBar!.respondsToSelector(selector) {
            statusBar!.performSelector(selector, withObject: color)
        }
    }


}
