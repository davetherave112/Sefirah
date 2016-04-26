//
//  SettingsTableViewController.swift
//  Sefirah
//
//  Created by Josh Siegel on 4/25/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var selectedLanguage: UILabel!
    @IBOutlet weak var selectedNusach: UILabel!
    @IBOutlet weak var prayerOptions: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
