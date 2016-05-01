//
//  PrayerOptionsRowController.swift
//  Sefirah
//
//  Created by Josh Siegel on 5/1/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import WatchKit

class PrayerOptionsRowController: NSObject {
    @IBOutlet var separator: WKInterfaceSeparator!
    @IBOutlet var prayerLabel: WKInterfaceLabel!
    @IBOutlet var checkImage: WKInterfaceImage!
    
    var prayerOption: Options? {
        didSet {
            if let prayerOption = prayerOption {
                prayerLabel.setText(prayerOption.rawValue)
                let selectedOptions = NSUserDefaults.standardUserDefaults().arrayForKey("Options") as! [String]
                if selectedOptions.contains(prayerOption.rawValue) {
                    self.checkImage.setHidden(false)
                }
            }
        }
    }
}
