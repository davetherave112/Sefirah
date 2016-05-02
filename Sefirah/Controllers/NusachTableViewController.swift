//
//  NusachTableViewController.swift
//  Sefirah
//
//  Created by Josh Siegel on 4/26/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import UIKit

class NusachTableViewController: UITableViewController {

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
        return Nusach.allValues.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NusachCell", forIndexPath: indexPath)
        
        cell.textLabel!.text = Nusach.allValues[indexPath.row].rawValue
        let selectedNusach = Nusach(rawValue: NSUserDefaults.standardUserDefaults().stringForKey("Nusach")!)
        if selectedNusach == Nusach.allValues[indexPath.row] {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
        let nusach = Nusach.allValues[indexPath.row].rawValue
        NSUserDefaults.standardUserDefaults().setValue(nusach, forKey: "Nusach")
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = .None
    }



}
