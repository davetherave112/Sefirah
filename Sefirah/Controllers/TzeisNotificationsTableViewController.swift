//
//  TzeisNotificationsTableViewController.swift
//  Sefirah
//
//  Created by Josh Siegel on 5/2/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import UIKit
import CoreLocation

class TzeisNotificationsTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    let identifier = "TzeisCell"
    let tzeisBefore = Tzeis.beforeValues
    let tzeisAfter = Tzeis.afterValues
    let locationManager = SefiraDay.sharedInstance.locationManager
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if SefiraDay.sharedInstance.lastRecordedCLLocation == nil {
            //locationManager.delegate = self
            //SefiraDay.sharedInstance.getLocation()
        }
    }
    
    /*
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = locations.last!.coordinate
        locationManager.delegate = self
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    */
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Before"
        } else if section == 2 {
            return "After"
        } else {
            return "Tzeis"
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return self.tzeisBefore.count
        } else {
            return self.tzeisAfter.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section > 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! TzeisNotificationTableViewCell
            if indexPath.section == 1 {
                let option = self.tzeisBefore[indexPath.row]
                cell.tzeisNotification = option
                cell.textLabel?.text = option.description
            } else {
                let option = self.tzeisAfter[indexPath.row]
                cell.tzeisNotification = option
                cell.textLabel?.text = option.description
            }
            
            return cell
        } else if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("TimeCell", forIndexPath: indexPath)
            if let location = SefiraDay.sharedInstance.lastRecordedCLLocation {
                let tzeis = SefiraDay.getTzeis(location)
                let timeFormatter = NSDateFormatter()
                timeFormatter.setLocalizedDateFormatFromTemplate("hh/mm a")
                let timeString: String = timeFormatter.stringFromDate(tzeis)
                cell.detailTextLabel?.text = timeString
                cell.textLabel?.text = "Local Time"
            } else {
                let success = SefiraDay.sharedInstance.getLocation()
                if !success {
                    let alert = UIAlertController(title: "Error", message: "Unauthorized GPS Access. Please open Sefirah on your iPhone and tap on current location.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            return
        }
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TzeisNotificationTableViewCell
        if cell.accessoryType == .Checkmark {
            cell.accessoryType = .None
        } else {
            cell.accessoryType = .Checkmark
        }
        
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications
        
        let option = cell.tzeisNotification!
        
        var savedOptions = NSUserDefaults.standardUserDefaults().arrayForKey("Tzeis") as! [Double]
        if cell.accessoryType == .Checkmark {
            savedOptions.append(option.rawValue)
            NSUserDefaults.standardUserDefaults().setObject(savedOptions, forKey: "Tzeis")
            NotificationManager.sharedInstance.getLocation()
        } else {
            let index = savedOptions.indexOf(option.rawValue)
            savedOptions.removeAtIndex(index!)
            let notification = notifications?.filter({($0.userInfo!["name"] as! String) == option.notificationName}).first
            if let notification = notification {
                UIApplication.sharedApplication().cancelLocalNotification(notification)
            }
            NSUserDefaults.standardUserDefaults().setObject(savedOptions, forKey: "Tzeis")
        }
        
        self.tableView.reloadData()
    }


}
