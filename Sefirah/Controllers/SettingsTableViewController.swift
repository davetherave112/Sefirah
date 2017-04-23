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
    @IBOutlet weak var tzeisOptions: UILabel!
    
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

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.selectedLanguage.text = UserDefaults.standard.string(forKey: "Language")
        self.selectedNusach.text = UserDefaults.standard.string(forKey: "Nusach")
        self.prayerOptions.text = (UserDefaults.standard.array(forKey: "Options") as! [String]).joined(separator: ", ")
        let tzeisTimes = (UserDefaults.standard.array(forKey: "Tzeis") as! [Double]).map({Tzeis(rawValue: $0)!.description})
        self.tzeisOptions.text = tzeisTimes.joined(separator: ", ")
        
        var notifications: [Notification] = []
        do {
            try db.operation { (context, save) throws -> Void in
                notifications = try context.fetch(FetchRequest<Notification>())
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
