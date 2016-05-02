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

        self.setStatusBarColor(UIColor(rgba: "#0E386C"))
        // Do any additional setup after loading the view.
        if let selectedDates = NSUserDefaults.standardUserDefaults().arrayForKey("SelectedDates") as? [NSDate] {
            let date = NSDate()
            let flags: NSCalendarUnit = [.Year, .Month, .Day]
            let components = NSCalendar.currentCalendar().components(flags, fromDate: date)
            let dateOnly = NSCalendar.currentCalendar().dateFromComponents(components)
            if !selectedDates.contains(dateOnly!) {
                let tabBarItem = self.tabBar.items![1]
                tabBarItem.badgeValue = "1"
                UIApplication.sharedApplication().applicationIconBadgeNumber = 1
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
            self.setStatusBarColor(UIColor(rgba: "#0E386C"))
        } else if item.tag == 1 {
            self.setStatusBarColor(UIColor(rgba: "#C19F69"))
        } else if item.tag == 2 {
            self.setStatusBarColor(UIColor(rgba: "#C19F69"))
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
