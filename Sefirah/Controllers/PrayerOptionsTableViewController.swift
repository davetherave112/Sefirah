//
//  PrayerOptionsTableViewController.swift
//  Sefirah
//
//  Created by Josh Siegel on 4/26/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import UIKit

class PrayerOptionsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
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
        return Options.allValues.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OptionsCell", forIndexPath: indexPath)
        
        cell.textLabel!.text = Options.allValues[indexPath.row].rawValue
        let selectedOptions = NSUserDefaults.standardUserDefaults().arrayForKey("Options") as! [String]
        if selectedOptions.contains(Options.allValues[indexPath.row].rawValue) {
            cell.accessoryType = .Checkmark
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.accessoryType == .Checkmark {
            cell?.accessoryType = .None
        } else {
            cell?.accessoryType = .Checkmark
        }
        let options = Options.allValues[indexPath.row].rawValue
        
        var savedOptions = NSUserDefaults.standardUserDefaults().arrayForKey("Options") as! [String]
        if cell?.accessoryType == .Checkmark {
            savedOptions.append(options)
        } else {
            let index = savedOptions.indexOf(Options.allValues[indexPath.row].rawValue)
            savedOptions.removeAtIndex(index!)
        }
        
        NSUserDefaults.standardUserDefaults().setValue(savedOptions, forKey: "Options")
        self.tableView.reloadData()
    }
    


}
