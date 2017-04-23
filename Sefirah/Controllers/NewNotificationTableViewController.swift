//
//  NewNotificationTableViewController.swift
//  Sefirah
//
//  Created by Josh Siegel on 4/26/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class NewNotificationTableViewController: UITableViewController {

    let kPickerAnimationDuration = 0.40 // duration for the animation to slide the date picker into view
    let kDatePickerTag           = 99   // view tag identifiying the date picker view
    let kTextFieldTag            = 20
    
    let kTitleKey = "title" // key for obtaining the data source item's title
    let kDateKey  = "date"  // key for obtaining the data source item's date value
    
    // keep track of which rows have date cells
    let kDateRow = 0
    let kTimeRow = 1
    
    let kDateCellID       = "dateCell";       // the cells with the start or end date
    let kDatePickerCellID = "datePickerCell"; // the cell containing the date picker
    let kOtherCellID      = "otherCell";      // the remaining cells at the end
    let kSwitchCellID     = "switchCell";
    
    var dataArray: [[String: AnyObject]] = []
    var dateFormatter = DateFormatter()
    var timeFormatter = DateFormatter()
    
    var currentSelectedDate: String?
    var currentSelectedTime: String?
    // keep track which indexPath points to the cell with UIDatePicker
    var datePickerIndexPath: IndexPath?
    
    var pickerCellRowHeight: CGFloat = 216
    
    @IBOutlet var pickerView: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        let cancelButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(cancel))
        cancelButton.tintColor = UIColor(rgba: "#ab8454")
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        let createButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(create))
        createButton.tintColor = UIColor(rgba: "#ab8454")
        self.navigationItem.rightBarButtonItem = createButton;
        
        // setup our data source
        let itemOne = [kTitleKey : "Date", kDateKey : Date()] as [String : Any]
        let itemTwo = [kTitleKey : "Time", kDateKey : Date()] as [String : Any]

        dataArray = [itemOne as Dictionary<String, AnyObject>, itemTwo as Dictionary<String, AnyObject>]
        
        dateFormatter.dateStyle = .medium // show short-style date format
        dateFormatter.timeStyle = .none
        
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short

        
        NotificationCenter.default.addObserver(self, selector: #selector(NewNotificationTableViewController.localeChanged(_:)), name: NSLocale.currentLocaleDidChangeNotification, object: nil)
    }
    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func create(_ sender: AnyObject) {
        let textField = tableView.viewWithTag(kTextFieldTag) as! UITextField
        let name = textField.text
        
        if !name!.isEmpty {
            if let date = mergeTimeAndDate() {
                NotificationManager.sharedInstance.scheduleLocal(name!, fireDate: date, repeatAlert: true)
                let tabBarController = self.presentingViewController as! UITabBarController
                let navController = tabBarController.selectedViewController as! UINavigationController
                let notificationsVC = navController.viewControllers.last as! NotificationsTableViewController
                self.dismiss(animated: true, completion: {
                    notificationsVC.tableView.reloadData()
                })
            } else {
                //TODO: show alert view
            }
        }
    }
    
    func mergeTimeAndDate() -> Date? {
        let df = DateFormatter()
        df.dateFormat = "MMM dd, yyyy hh:mm a"
        if currentSelectedDate != nil && currentSelectedTime != nil {
            let dateString = currentSelectedDate! + " " + currentSelectedTime!
            if let dateFromString = df.date(from: dateString) {
                return dateFromString
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func localeChanged(_ notif: Foundation.Notification) {
        tableView.reloadData()
    }
    
    // Check if cell has picker
    func hasPickerForIndexPath(_ indexPath: IndexPath) -> Bool {
        var hasDatePicker = false
        
        let targetedRow = (indexPath as NSIndexPath).row + 1
        
        let checkDatePickerCell = tableView.cellForRow(at: IndexPath(row: targetedRow, section: 1))
        let checkDatePicker = checkDatePickerCell?.viewWithTag(kDatePickerTag)
        
        hasDatePicker = checkDatePicker != nil
        return hasDatePicker
    }
    
    // Match above cell
    func updateDatePicker() {
        if let indexPath = datePickerIndexPath {
            let associatedDatePickerCell = tableView.cellForRow(at: indexPath)
            if let targetedDatePicker = associatedDatePickerCell?.viewWithTag(kDatePickerTag) as! UIDatePicker? {
                let itemData = dataArray[(self.datePickerIndexPath! as NSIndexPath).row - 1]
                targetedDatePicker.setDate(itemData[kDateKey] as! Date, animated: false)
                if (indexPath as NSIndexPath).row - 1 == kDateRow {
                    targetedDatePicker.datePickerMode = .date
                } else if (indexPath as NSIndexPath).row - 1 == kTimeRow {
                    targetedDatePicker.datePickerMode = .time
                }
            }
        }
    }
    
    func inlineDatePickerShowing() -> Bool {
        return datePickerIndexPath != nil
    }
    
    func indexPathIsPicker(_ indexPath: IndexPath) -> Bool {
        return inlineDatePickerShowing() && (datePickerIndexPath as NSIndexPath?)?.row == (indexPath as NSIndexPath).row && (indexPath as NSIndexPath).section == 1
    }
    
    /*! Determines if the given indexPath points to a cell that contains the start/end dates.
     
     @param indexPath The indexPath to check if it represents start/end date cell.
     */
    func indexPathHasDate(_ indexPath: IndexPath) -> Bool {
        var hasDate = false
        
        if (((indexPath as NSIndexPath).row == kDateRow) || ((indexPath as NSIndexPath).row == kTimeRow || (inlineDatePickerShowing() && ((indexPath as NSIndexPath).row == kTimeRow + 1)))) && ((indexPath as NSIndexPath).section == 1) {
            hasDate = true
        }
        return hasDate
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPathIsPicker(indexPath) ? pickerCellRowHeight : 55)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if inlineDatePickerShowing() {
                // we have a date picker, so allow for it in the number of rows in this section
                return dataArray.count + 1;
            }
            return dataArray.count;
        case 2:
            return 1
        default:
            return 0
        }
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        var cellID = kOtherCellID
        
        
        if indexPathIsPicker(indexPath) {
            // the indexPath is the one containing the inline date picker
            cellID = kDatePickerCellID     // the current/opened date picker cell
            
        } else if indexPathHasDate(indexPath) {
            // the indexPath is one that contains the date information
            cellID = kDateCellID       // the start/end date cells
        } else if (indexPath as NSIndexPath).section == 2 {
            cellID = kSwitchCellID
        }
        
        cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        
        
        // if we have a date picker open whose cell is above the cell we want to update,
        // then we have one more cell than the model allows - makes sure we're not updating a picker cell
        //
        
        var modelRow = (indexPath as NSIndexPath).row
        if (datePickerIndexPath != nil && (datePickerIndexPath as NSIndexPath?)?.row <= (indexPath as NSIndexPath).row) {
            modelRow -= 1
        }
        
        let itemData = dataArray[modelRow]
        
        if cellID == kDateCellID {
            cell?.textLabel?.text = itemData[kTitleKey] as? String
            if (indexPath as NSIndexPath).row == kDateRow {
                let date = itemData[kDateKey] as! Date
                cell?.detailTextLabel?.text = self.dateFormatter.string(from: date)
                currentSelectedDate = cell?.detailTextLabel?.text
            } else if (indexPath as NSIndexPath).row == kTimeRow {
                let date = itemData[kDateKey] as! Date
                cell?.detailTextLabel?.text = self.timeFormatter.string(from: date)
                currentSelectedTime = cell?.detailTextLabel?.text
                
            }
        } else if cellID == kOtherCellID {
           // Can put something here
        }
        
        return cell!
    }
    
    /*! Adds or removes a UIDatePicker cell below the given indexPath.
     
     @param indexPath The indexPath to reveal the UIDatePicker.
     */
    func toggleDatePickerForSelectedIndexPath(_ indexPath: IndexPath) {
        tableView.beginUpdates()
        
        let indexPaths = [IndexPath(row: (indexPath as NSIndexPath).row + 1, section: 1)]
        
        // check if 'indexPath' has an attached date picker below it
        if hasPickerForIndexPath(indexPath) {
            // found a picker below it, so remove it
            tableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            // didn't find a picker below it, so we should insert it
            tableView.insertRows(at: indexPaths, with: .fade)
        }
        tableView.endUpdates()
    }
    
    /*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
     
     @param indexPath The indexPath to reveal the UIDatePicker.
     */
    func displayInlineDatePickerForRowAtIndexPath(_ indexPath: IndexPath) {
        
        // display the date picker inline with the table content
        tableView.beginUpdates()
        
        var before = false // indicates if the date picker is below "indexPath", help us determine which row to reveal
        if inlineDatePickerShowing() {
            before = (datePickerIndexPath as NSIndexPath?)?.row < (indexPath as NSIndexPath).row
        }
        
        let sameCellClicked = ((datePickerIndexPath as NSIndexPath?)?.row == (indexPath as NSIndexPath).row + 1)
        
        // remove any date picker cell if it exists
        if self.inlineDatePickerShowing() {
            tableView.deleteRows(at: [IndexPath(row: (datePickerIndexPath! as NSIndexPath).row, section: 1)], with: .fade)
            datePickerIndexPath = nil
        }
        
        if !sameCellClicked {
            // hide the old date picker and display the new one
            let rowToReveal = (before ? (indexPath as NSIndexPath).row - 1 : (indexPath as NSIndexPath).row)
            let indexPathToReveal = IndexPath(row: rowToReveal, section: 1)
            
            toggleDatePickerForSelectedIndexPath(indexPathToReveal)
            datePickerIndexPath = IndexPath(row: (indexPathToReveal as NSIndexPath).row + 1, section: 1)
        }
        
        // always deselect the row containing the start or end date
        tableView.deselectRow(at: indexPath, animated:true)
        
        tableView.endUpdates()
        
        // inform our date picker of the current date to match the current cell
        updateDatePicker()
    }
    
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.reuseIdentifier == kDateCellID {
            displayInlineDatePickerForRowAtIndexPath(indexPath)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    // MARK: - Actions
    
    /*! User chose to change the date by changing the values inside the UIDatePicker.
     
     @param sender The sender for this action: UIDatePicker.
     */
    
    
    @IBAction func dateAction(_ sender: UIDatePicker) {
        
        var targetedCellIndexPath: IndexPath?
        
        if self.inlineDatePickerShowing() {
            // inline date picker: update the cell's date "above" the date picker cell
            //
            targetedCellIndexPath = IndexPath(row: (datePickerIndexPath! as NSIndexPath).row - 1, section: 1)
        } else {
            // external date picker: update the current "selected" cell's date
            targetedCellIndexPath = tableView.indexPathForSelectedRow!
        }
        
        let cell = tableView.cellForRow(at: targetedCellIndexPath!)
        let targetedDatePicker = sender
        
        // update our data model
        var itemData = dataArray[(targetedCellIndexPath! as NSIndexPath).row]
        itemData[kDateKey] = targetedDatePicker.date as AnyObject?
        dataArray[(targetedCellIndexPath! as NSIndexPath).row] = itemData
        
        // update the cell's date string
        if (targetedCellIndexPath! as NSIndexPath).row == kDateRow {
            cell?.detailTextLabel?.text = dateFormatter.string(from: targetedDatePicker.date)
            currentSelectedDate = cell?.detailTextLabel?.text
        } else if (targetedCellIndexPath! as NSIndexPath).row == kTimeRow {
            cell?.detailTextLabel?.text = timeFormatter.string(from: targetedDatePicker.date)
            currentSelectedTime = cell?.detailTextLabel?.text
        }
        
        
    }

}
