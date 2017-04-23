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
        let store = CoreDataStore.named("db")
        let bundle = Bundle(for: self.classForCoder)
        let model = CoreDataObjectModel.merged([bundle])
        let defaultStorage = try! CoreDataDefaultStorage(store: store, model: model)
        return defaultStorage
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        let nibName = UINib(nibName: "NotificationCell", bundle:nil)
        self.tableView.register(nibName, forCellReuseIdentifier: "NotificationCell")
        
        let addButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addItem))
        addButton.tintColor = UIColor(rgba: "#ab8454")
        
        self.navigationItem.rightBarButtonItem = addButton;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Notification.destroyExpiredNotifications()
        
        self.notifications = Notification.fetchAllNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.notifications.count > 0 {
            self.tableView.backgroundView = nil
        } else {
            let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: backgroundView.bounds.size.width, height: backgroundView.bounds.size.height/2))
            noDataLabel.text = "You Have No Notifications"
            noDataLabel.textColor = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
            noDataLabel.textAlignment = NSTextAlignment.center
            backgroundView.addSubview(noDataLabel)
            self.tableView.backgroundView = backgroundView
        }
        return self.notifications.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationTableViewCell

            let notification: Notification = notifications[(indexPath as NSIndexPath).row]
            
            cell.notification = notification
            
            let dateFormatter = DateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("MM/dd")
            let timeFormatter = DateFormatter()
            timeFormatter.setLocalizedDateFormatFromTemplate("hh:mm")
            
            let dateString: String = dateFormatter.string(from: notification.date! as Date)
            let timeString: String = timeFormatter.string(from: notification.date! as Date)
 
            cell.nameLabel.text = notification.name
            cell.dateLabel.text = "\(dateString) - \(timeString)"
            cell.delegate = tableView
        
            let enabled = notification.enabled as! Bool
            enabled ? cell.notificationSwitch.setOn(true, animated: false) : cell.notificationSwitch.setOn(false, animated: false)

        
        return cell
    }
   
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func addItem(_ sender: AnyObject) {
        let newNotificationController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NotificationNavigationController") as! UINavigationController
        self.present(newNotificationController, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! NotificationTableViewCell
        if editingStyle == UITableViewCellEditingStyle.delete {
            let name = cell.notification.name
            try! db.operation({ (context, save) -> Void in
                guard let obj = try! context.request(Notification.self).filtered(with: "name", equalTo: name!).fetch().first else { return }
                _ = try? context.remove(obj)
                save()
            })
            updateData()
        }
    }
    
    fileprivate func updateData() {
        self.notifications = try! db.fetch(FetchRequest<Notification>()).map{$0}
    }
    


}
