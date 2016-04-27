//
//  NotificationsTableViewController.swift
//  Sefirah
//
//  Created by Josh Siegel on 4/26/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import Foundation
import UIKit
import SugarRecord
import CoreData

class NotificationsTableViewController: UITableViewController {

    var notifications: [Notification] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    lazy var db: CoreDataDefaultStorage = {
        let store = CoreData.Store.Named("db")
        let bundle = NSBundle(forClass: self.classForCoder)
        let model = CoreData.ObjectModel.Merged([bundle])
        let defaultStorage = try! CoreDataDefaultStorage(store: store, model: model)
        return defaultStorage
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        let nibName = UINib(nibName: "NotificationCell", bundle:nil)
        self.tableView.registerNib(nibName, forCellReuseIdentifier: "NotificationCell")
        
        let addButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(addItem))
        
        self.navigationItem.rightBarButtonItem = addButton;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        Notification.destroyExpiredNotifications()
        
        self.notifications = Notification.fetchAllNotifications()
        /*
        if let notifications = (NSUserDefaults.standardUserDefaults().objectForKey("Notifications"))  {
            var notificationsDict = NotificationManager.sharedInstance.getNotificationsDictionary()!
            for (name, data) in notificationsDict {
                if data[true] != nil {
                    if data[true]!.compare(NSDate()) == NSComparisonResult.OrderedAscending {
                        notificationsDict.removeValueForKey(name)
                        let keyedArch = NSKeyedArchiver.archivedDataWithRootObject(notificationsDict)
                        NSUserDefaults.standardUserDefaults().setObject(keyedArch, forKey: "Notifications")
                    }
                }
            }
        }
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*
        if let notifications = self.notifications {
            return self.notifications!.count
        } else {
            return 0
        }
        */
        return self.notifications.count
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }

   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationCell", forIndexPath: indexPath) as! NotificationTableViewCell

        /*
        if let notifications = (NSUserDefaults.standardUserDefaults().objectForKey("Notifications"))  {
            let notificationsDict = NotificationManager.sharedInstance.getNotificationsDictionary()!
            let filtered = notificationsDict.filter { _,_ in true }
            */
        //if let notifications = self.notifications {
            let notification: Notification = notifications[indexPath.row] //filtered[indexPath.row]
            
            cell.notification = notification
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("MM/dd")
            let timeFormatter = NSDateFormatter()
            timeFormatter.setLocalizedDateFormatFromTemplate("hh:mm")
            
            var dateString: String = dateFormatter.stringFromDate(notification.date!)
            var timeString: String = timeFormatter.stringFromDate(notification.date!)
            
            /*
            if notification.1[true] != nil {
                dateString = dateFormatter.stringFromDate(notification.1[true]!)
                timeString = timeFormatter.stringFromDate(notification.1[true]!)
            } else {
                dateString = dateFormatter.stringFromDate(notification.1[false]!)
                timeString = timeFormatter.stringFromDate(notification.1[false]!)
            }
            */
 
            
            cell.nameLabel.text = notification.name //notification.0
            cell.dateLabel.text = "\(dateString) - \(timeString)"
            cell.delegate = tableView
        
            let enabled = notification.enabled as! Bool
            enabled ? cell.notificationSwitch.setOn(true, animated: false) : cell.notificationSwitch.setOn(false, animated: false)
            /*
            if notificationsDict[cell.nameLabel.text!]![true] != nil {
                cell.notificationSwitch.setOn(true, animated: false)
            } else {
                cell.notificationSwitch.setOn(false, animated: false)
            }
            */
        //}
        
        return cell
    }
   
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func addItem(sender: AnyObject) {
        let newNotificationController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("NotificationNavigationController") as! UINavigationController
        self.presentViewController(newNotificationController, animated: true, completion: nil)
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! NotificationTableViewCell
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let name = cell.notification.name
            try! db.operation({ (context, save) -> Void in
                guard let obj = try! context.request(Notification.self).filteredWith("name", equalTo: name!).fetch().first else { return }
                _ = try? context.remove(obj)
                save()
            })
            updateData()
        }
    }
    
    private func updateData() {
        self.notifications = try! db.fetch(Request<Notification>()).map{$0}
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
