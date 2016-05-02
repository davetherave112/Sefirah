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
        addButton.tintColor = UIColor(rgba: "#C19F69")
        
        self.navigationItem.rightBarButtonItem = addButton;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        Notification.destroyExpiredNotifications()
        
        self.notifications = Notification.fetchAllNotifications()
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
        if self.notifications.count > 0 {
            self.tableView.backgroundView = nil
        } else {
            let backgroundView = UIView(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
            let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, backgroundView.bounds.size.width, backgroundView.bounds.size.height/2))
            noDataLabel.text = "You Have No Notifications"
            noDataLabel.textColor = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
            noDataLabel.textAlignment = NSTextAlignment.Center
            backgroundView.addSubview(noDataLabel)
            self.tableView.backgroundView = backgroundView
        }
        return self.notifications.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }

   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationCell", forIndexPath: indexPath) as! NotificationTableViewCell

            let notification: Notification = notifications[indexPath.row]
            
            cell.notification = notification
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("MM/dd")
            let timeFormatter = NSDateFormatter()
            timeFormatter.setLocalizedDateFormatFromTemplate("hh:mm")
            
            let dateString: String = dateFormatter.stringFromDate(notification.date!)
            let timeString: String = timeFormatter.stringFromDate(notification.date!)
 
            cell.nameLabel.text = notification.name
            cell.dateLabel.text = "\(dateString) - \(timeString)"
            cell.delegate = tableView
        
            let enabled = notification.enabled as! Bool
            enabled ? cell.notificationSwitch.setOn(true, animated: false) : cell.notificationSwitch.setOn(false, animated: false)

        
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
    


}
