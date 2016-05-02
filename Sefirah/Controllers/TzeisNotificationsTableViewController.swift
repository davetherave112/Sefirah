//
//  TzeisNotificationsTableViewController.swift
//  Sefirah
//
//  Created by Josh Siegel on 5/2/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import UIKit

class TzeisNotificationsTableViewController: UITableViewController {
    
    let identifier = "TzeisCell"
    let tzeisBefore = Tzeis.beforeValues
    let tzeisAfter = Tzeis.afterValues
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Before"
        } else {
            return "After"
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.tzeisBefore.count
        } else {
            return self.tzeisAfter.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! TzeisNotificationTableViewCell
        if indexPath.section == 0 {
            let option = self.tzeisBefore[indexPath.row]
            cell.tzeisNotification = option
            cell.textLabel?.text = option.description
        } else {
            let option = self.tzeisAfter[indexPath.row]
            cell.tzeisNotification = option
            cell.textLabel?.text = option.description
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TzeisNotificationTableViewCell
        if cell.accessoryType == .Checkmark {
            cell.accessoryType = .None
        } else {
            cell.accessoryType = .Checkmark
        }
        
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        
        let option = cell.tzeisNotification!
        
        var savedOptions = NSUserDefaults.standardUserDefaults().arrayForKey("Tzeis") as! [Int]
        if cell.accessoryType == .Checkmark {
            savedOptions.append(option.rawValue)
            NSUserDefaults.standardUserDefaults().setValue(savedOptions, forKey: "Tzeis")
            NotificationManager.sharedInstance.getLocation()
        } else {
            let index = savedOptions.indexOf(option.rawValue)
            savedOptions.removeAtIndex(index!)
            let notification = notifications?.filter({($0.userInfo!["name"] as! String) == option.notificationName}).first
            if let notification = notification {
                UIApplication.sharedApplication().cancelLocalNotification(notification)
            }
            NSUserDefaults.standardUserDefaults().setValue(savedOptions, forKey: "Tzeis")
        }
        
        self.tableView.reloadData()
    }


}
