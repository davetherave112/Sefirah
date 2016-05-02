//
//  NewNotificationTableViewController.swift
//  Sefirah
//
//  Created by Josh Siegel on 4/26/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import UIKit

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
    var dateFormatter = NSDateFormatter()
    var timeFormatter = NSDateFormatter()
    
    var currentSelectedDate: String?
    var currentSelectedTime: String?
    // keep track which indexPath points to the cell with UIDatePicker
    var datePickerIndexPath: NSIndexPath?
    
    var pickerCellRowHeight: CGFloat = 216
    
    @IBOutlet var pickerView: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        let cancelButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(cancel))
        cancelButton.tintColor = UIColor(rgba: "#C19F69")
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        let createButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(create))
        createButton.tintColor = UIColor(rgba: "#C19F69")
        self.navigationItem.rightBarButtonItem = createButton;
        
        // setup our data source
        let itemOne = [kTitleKey : "Date", kDateKey : NSDate()]
        let itemTwo = [kTitleKey : "Time", kDateKey : NSDate()]

        dataArray = [itemOne, itemTwo]
        
        dateFormatter.dateStyle = .MediumStyle // show short-style date format
        dateFormatter.timeStyle = .NoStyle
        
        timeFormatter.dateStyle = .NoStyle
        timeFormatter.timeStyle = .ShortStyle

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewNotificationTableViewController.localeChanged(_:)), name: NSCurrentLocaleDidChangeNotification, object: nil)
    }
    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func create(sender: AnyObject) {
        let textField = tableView.viewWithTag(kTextFieldTag) as! UITextField
        let name = textField.text
        
        if !name!.isEmpty {
            if let date = mergeTimeAndDate() {
                NotificationManager.sharedInstance.scheduleLocal(name!, fireDate: date, repeatAlert: true)
                let tabBarController = self.presentingViewController as! UITabBarController
                let navController = tabBarController.selectedViewController as! UINavigationController
                let notificationsVC = navController.viewControllers.last as! NotificationsTableViewController
                self.dismissViewControllerAnimated(true, completion: {
                    notificationsVC.tableView.reloadData()
                })
            } else {
                //TODO: show alert view
            }
        }
    }
    
    func mergeTimeAndDate() -> NSDate? {
        let df = NSDateFormatter()
        df.dateFormat = "MMM dd, yyyy hh:mm a"
        if currentSelectedDate != nil && currentSelectedTime != nil {
            let dateString = currentSelectedDate! + " " + currentSelectedTime!
            if let dateFromString = df.dateFromString(dateString) {
                return dateFromString
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func localeChanged(notif: NSNotification) {
        tableView.reloadData()
    }
    
    // Check if cell has picker
    func hasPickerForIndexPath(indexPath: NSIndexPath) -> Bool {
        var hasDatePicker = false
        
        let targetedRow = indexPath.row + 1
        
        let checkDatePickerCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: targetedRow, inSection: 1))
        let checkDatePicker = checkDatePickerCell?.viewWithTag(kDatePickerTag)
        
        hasDatePicker = checkDatePicker != nil
        return hasDatePicker
    }
    
    // Match above cell
    func updateDatePicker() {
        if let indexPath = datePickerIndexPath {
            let associatedDatePickerCell = tableView.cellForRowAtIndexPath(indexPath)
            if let targetedDatePicker = associatedDatePickerCell?.viewWithTag(kDatePickerTag) as! UIDatePicker? {
                let itemData = dataArray[self.datePickerIndexPath!.row - 1]
                targetedDatePicker.setDate(itemData[kDateKey] as! NSDate, animated: false)
                if indexPath.row - 1 == kDateRow {
                    targetedDatePicker.datePickerMode = .Date
                } else if indexPath.row - 1 == kTimeRow {
                    targetedDatePicker.datePickerMode = .Time
                }
            }
        }
    }
    
    func inlineDatePickerShowing() -> Bool {
        return datePickerIndexPath != nil
    }
    
    func indexPathIsPicker(indexPath: NSIndexPath) -> Bool {
        return inlineDatePickerShowing() && datePickerIndexPath?.row == indexPath.row && indexPath.section == 1
    }
    
    /*! Determines if the given indexPath points to a cell that contains the start/end dates.
     
     @param indexPath The indexPath to check if it represents start/end date cell.
     */
    func indexPathHasDate(indexPath: NSIndexPath) -> Bool {
        var hasDate = false
        
        if ((indexPath.row == kDateRow) || (indexPath.row == kTimeRow || (inlineDatePickerShowing() && (indexPath.row == kTimeRow + 1)))) && (indexPath.section == 1) {
            hasDate = true
        }
        return hasDate
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (indexPathIsPicker(indexPath) ? pickerCellRowHeight : 55)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        var cellID = kOtherCellID
        
        
        if indexPathIsPicker(indexPath) {
            // the indexPath is the one containing the inline date picker
            cellID = kDatePickerCellID     // the current/opened date picker cell
            
        } else if indexPathHasDate(indexPath) {
            // the indexPath is one that contains the date information
            cellID = kDateCellID       // the start/end date cells
        } else if indexPath.section == 2 {
            cellID = kSwitchCellID
        }
        
        cell = tableView.dequeueReusableCellWithIdentifier(cellID)
        
        
        // if we have a date picker open whose cell is above the cell we want to update,
        // then we have one more cell than the model allows - makes sure we're not updating a picker cell
        //
        
        var modelRow = indexPath.row
        if (datePickerIndexPath != nil && datePickerIndexPath?.row <= indexPath.row) {
            modelRow -= 1
        }
        
        let itemData = dataArray[modelRow]
        
        if cellID == kDateCellID {
            cell?.textLabel?.text = itemData[kTitleKey] as? String
            if indexPath.row == kDateRow {
                let date = itemData[kDateKey] as! NSDate
                cell?.detailTextLabel?.text = self.dateFormatter.stringFromDate(date)
                currentSelectedDate = cell?.detailTextLabel?.text
            } else if indexPath.row == kTimeRow {
                let date = itemData[kDateKey] as! NSDate
                cell?.detailTextLabel?.text = self.timeFormatter.stringFromDate(date)
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
    func toggleDatePickerForSelectedIndexPath(indexPath: NSIndexPath) {
        tableView.beginUpdates()
        
        let indexPaths = [NSIndexPath(forRow: indexPath.row + 1, inSection: 1)]
        
        // check if 'indexPath' has an attached date picker below it
        if hasPickerForIndexPath(indexPath) {
            // found a picker below it, so remove it
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        } else {
            // didn't find a picker below it, so we should insert it
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        }
        tableView.endUpdates()
    }
    
    /*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
     
     @param indexPath The indexPath to reveal the UIDatePicker.
     */
    func displayInlineDatePickerForRowAtIndexPath(indexPath: NSIndexPath) {
        
        // display the date picker inline with the table content
        tableView.beginUpdates()
        
        var before = false // indicates if the date picker is below "indexPath", help us determine which row to reveal
        if inlineDatePickerShowing() {
            before = datePickerIndexPath?.row < indexPath.row
        }
        
        let sameCellClicked = (datePickerIndexPath?.row == indexPath.row + 1)
        
        // remove any date picker cell if it exists
        if self.inlineDatePickerShowing() {
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: datePickerIndexPath!.row, inSection: 1)], withRowAnimation: .Fade)
            datePickerIndexPath = nil
        }
        
        if !sameCellClicked {
            // hide the old date picker and display the new one
            let rowToReveal = (before ? indexPath.row - 1 : indexPath.row)
            let indexPathToReveal = NSIndexPath(forRow: rowToReveal, inSection: 1)
            
            toggleDatePickerForSelectedIndexPath(indexPathToReveal)
            datePickerIndexPath = NSIndexPath(forRow: indexPathToReveal.row + 1, inSection: 1)
        }
        
        // always deselect the row containing the start or end date
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        
        tableView.endUpdates()
        
        // inform our date picker of the current date to match the current cell
        updateDatePicker()
    }
    
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.reuseIdentifier == kDateCellID {
            displayInlineDatePickerForRowAtIndexPath(indexPath)
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    
    // MARK: - Actions
    
    /*! User chose to change the date by changing the values inside the UIDatePicker.
     
     @param sender The sender for this action: UIDatePicker.
     */
    
    
    @IBAction func dateAction(sender: UIDatePicker) {
        
        var targetedCellIndexPath: NSIndexPath?
        
        if self.inlineDatePickerShowing() {
            // inline date picker: update the cell's date "above" the date picker cell
            //
            targetedCellIndexPath = NSIndexPath(forRow: datePickerIndexPath!.row - 1, inSection: 1)
        } else {
            // external date picker: update the current "selected" cell's date
            targetedCellIndexPath = tableView.indexPathForSelectedRow!
        }
        
        let cell = tableView.cellForRowAtIndexPath(targetedCellIndexPath!)
        let targetedDatePicker = sender
        
        // update our data model
        var itemData = dataArray[targetedCellIndexPath!.row]
        itemData[kDateKey] = targetedDatePicker.date
        dataArray[targetedCellIndexPath!.row] = itemData
        
        // update the cell's date string
        if targetedCellIndexPath!.row == kDateRow {
            cell?.detailTextLabel?.text = dateFormatter.stringFromDate(targetedDatePicker.date)
            currentSelectedDate = cell?.detailTextLabel?.text
        } else if targetedCellIndexPath!.row == kTimeRow {
            cell?.detailTextLabel?.text = timeFormatter.stringFromDate(targetedDatePicker.date)
            currentSelectedTime = cell?.detailTextLabel?.text
        }
        
        
    }

}
