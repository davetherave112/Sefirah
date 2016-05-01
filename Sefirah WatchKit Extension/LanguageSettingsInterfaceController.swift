//
//  LanguageSettingsInterfaceController.swift
//  Sefirah
//
//  Created by Josh Siegel on 5/1/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import WatchKit
import Foundation


class LanguageSettingsInterfaceController: WKInterfaceController {

    @IBOutlet var languagesTable: WKInterfaceTable!
    var languages = Languages.allValues
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        loadTableData()
    }
    
    func loadTableData() {
        self.languagesTable.setNumberOfRows(languages.count, withRowType: "LanguageRow")
        for index in 0..<languagesTable.numberOfRows {
            if let controller = languagesTable.rowControllerAtIndex(index) as? LanguageRowController {
                controller.language = languages[index]
            }
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let language = languages[rowIndex]
        NSUserDefaults.standardUserDefaults().setValue(language.rawValue, forKey: "Language")
        loadTableData()
        
    }
}
