//
//  SettingsTableViewController.swift
//  Sefirah
//
//  Created by Josh Siegel on 4/25/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import UIKit
import CoreData
import SugarRecord

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var selectedLanguage: UILabel!
    @IBOutlet weak var selectedNusach: UILabel!
    @IBOutlet weak var prayerOptions: UILabel!
    @IBOutlet weak var notificationCount: UILabel!
    
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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.selectedLanguage.text = NSUserDefaults.standardUserDefaults().stringForKey("Language")
        self.selectedNusach.text = NSUserDefaults.standardUserDefaults().stringForKey("Nusach")
        self.prayerOptions.text = (NSUserDefaults.standardUserDefaults().arrayForKey("Options") as! [String]).joinWithSeparator(", ")
        
        var notifications: [Notification] = []
        do {
            try db.operation { (context, save) throws -> Void in
                notifications = try context.fetch(Request<Notification>())
            }
        }
        catch {
            //TODO: There was an error in the operation
        }
        
        
        self.notificationCount.text = "\(notifications.count)"
        
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
