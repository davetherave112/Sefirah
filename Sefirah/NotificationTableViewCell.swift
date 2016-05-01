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
    
    //TODO: Check switch is properly set
    @IBAction func switchChanged(sender: UISwitch) {
        let toggleSwitch = sender
        if !toggleSwitch.on {
            do {
               try db.operation { (context, save) throws -> Void in
                    self.notification.enabled = false
                    save()
                }
            }
            catch {
                //TODO: There was an error in the operation
            }
            
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
