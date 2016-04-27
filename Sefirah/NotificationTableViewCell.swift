//
//  NotificationTableViewCell.swift
//  Sefirah
//
//  Created by Josh Siegel on 4/26/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import SugarRecord

class NotificationTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!

    lazy var db: CoreDataDefaultStorage = {
        let store = CoreData.Store.Named("db")
        let bundle = NSBundle(forClass: self.classForCoder)
        let model = CoreData.ObjectModel.Merged([bundle])
        let defaultStorage = try! CoreDataDefaultStorage(store: store, model: model)
        return defaultStorage
    }()
    
    var notification: Notification!
    var delegate: UITableView?
    
    @IBAction func switchChanged(sender: UISwitch) {
        let toggleSwitch = sender as! UISwitch
        let indexPath = delegate?.indexPathForCell(self)
        if !toggleSwitch.on {
            //sender.setOn(false, animated: true)
            
            do {
               try db.operation { (context, save) throws -> Void in
                    self.notification.enabled = false
                    save()
                }
            }
            catch {
                //TODO: There was an error in the operation
            }
            
            /*
            var notificationsDict = NotificationManager.sharedInstance.getNotificationsDictionary()!
            let date = notificationsDict[self.nameLabel.text!]![true]
            notificationsDict[self.nameLabel.text!] = [false: date!]
            let keyedArch = NSKeyedArchiver.archivedDataWithRootObject(notificationsDict)
            NSUserDefaults.standardUserDefaults().setObject(keyedArch, forKey: "Notifications")
            */
            
            let allNotifications: [UILocalNotification] = NotificationManager.sharedInstance.getAllNotifications()
            for notification in allNotifications {
                if (notification.userInfo!["name"] as! String) == self.nameLabel.text! {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    return
                }
            }
 
        } else {
            do {
                try db.operation { (context, save) throws -> Void in
                    self.notification.enabled = true
                    save()
                }
            }
            catch {
                //TODO: There was an error in the operation
            }
            /*
            //sender.setOn(true, animated: true)
            if let notifications = (NSUserDefaults.standardUserDefaults().objectForKey("Notifications"))  {
                var notificationsDict = NotificationManager.sharedInstance.getNotificationsDictionary()!
                let date = notificationsDict[self.nameLabel.text!]![false]
                notificationsDict[self.nameLabel.text!] = [true: date!]
                let keyedArch = NSKeyedArchiver.archivedDataWithRootObject(notificationsDict)
                NSUserDefaults.standardUserDefaults().setObject(keyedArch, forKey: "Notifications")
            }
            */
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }

}
