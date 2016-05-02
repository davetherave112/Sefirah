//
//  LanguagesTableViewController.swift
//  Sefirah
//
//  Created by Josh Siegel on 4/25/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import UIKit
import KosherCocoa

class LanguagesTableViewController: UITableViewController {
    
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
        return Languages.allValues.count
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
 
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LanguageCell", forIndexPath: indexPath)
        
        cell.textLabel!.text = Languages.allValues[indexPath.row].rawValue
        let selectedLanguage = Languages(rawValue: NSUserDefaults.standardUserDefaults().stringForKey("Language")!)
        if selectedLanguage == Languages.allValues[indexPath.row] {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
        let language = Languages.allValues[indexPath.row].rawValue
        NSUserDefaults.standardUserDefaults().setValue(language, forKey: "Language")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
    }


}
