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
        if let selectedDates = UserDefaults.standard.array(forKey: "SelectedDates") as? [Date] {
            if let location = SefiraDay.sharedInstance.lastRecordedCLLocation {
                let adjustedDate = SefiraDay.dateAdjustedForHebrewCalendar(location, date: Date())
                if !selectedDates.contains(adjustedDate) {
                    let tabBarItem = self.tabBar.items![1]
                    tabBarItem.badgeValue = "1"
                    UIApplication.shared.applicationIconBadgeNumber = 1
                }
            }
        } else {
            let tabBarItem = self.tabBar.items![1]
            tabBarItem.badgeValue = "1"
            UIApplication.shared.applicationIconBadgeNumber = 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 0 {
            self.setStatusBarColor(UIColor(rgba: "#161543"))
        } else if item.tag == 1 {
            self.setStatusBarColor(UIColor(rgba: "#ab8454"))
        } else if item.tag == 2 {
            self.setStatusBarColor(UIColor(rgba: "#ab8454"))
        }
    }
    
    func setStatusBarColor(_ color: UIColor) {
        let statusBarWindow = UIApplication.shared.value(forKey: "statusBarWindow")
        let statusBar = (statusBarWindow! as AnyObject).value(forKey: "statusBar")
        let selector = #selector(setter: CATextLayer.foregroundColor)
        if (statusBar! as AnyObject).responds(to: selector) {
            (statusBar! as AnyObject).perform(selector, with: color)
        }
    }


}
