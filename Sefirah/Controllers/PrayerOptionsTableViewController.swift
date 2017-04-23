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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Options.allValues.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionsCell", for: indexPath)
        
        cell.textLabel!.text = Options.allValues[(indexPath as NSIndexPath).row].rawValue
        let selectedOptions = UserDefaults.standard.array(forKey: "Options") as! [String]
        if selectedOptions.contains(Options.allValues[(indexPath as NSIndexPath).row].rawValue) {
            cell.accessoryType = .checkmark
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.accessoryType == .checkmark {
            cell?.accessoryType = .none
        } else {
            cell?.accessoryType = .checkmark
        }
        let options = Options.allValues[(indexPath as NSIndexPath).row].rawValue
        
        var savedOptions = UserDefaults.standard.array(forKey: "Options") as! [String]
        if cell?.accessoryType == .checkmark {
            savedOptions.append(options)
        } else {
            let index = savedOptions.index(of: Options.allValues[(indexPath as NSIndexPath).row].rawValue)
            savedOptions.remove(at: index!)
        }
        
        UserDefaults.standard.setValue(savedOptions, forKey: "Options")
        self.tableView.reloadData()
    }
    


}
