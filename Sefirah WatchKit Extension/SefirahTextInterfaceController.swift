//
//  SefirahTextInterfaceController.swift
//  Sefirah
//
//  Created by Josh Siegel on 4/29/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import WatchKit
import Foundation
import KosherCocoa


class SefirahTextInterfaceController: WKInterfaceController {
    
    var formatter = KCSefiraFormatter()
    @IBOutlet var sefriahTextLabel: WKInterfaceLabel!
    let adjustedDay = SefiraDayWatch.sharedInstance
    
    @IBAction func languageSettings() {
        self.presentControllerWithName("LanguagesController", context: nil)
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        self.formatter = KCSefiraFormatter()

    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        let dayOfSefira = adjustedDay.sefiraDate
        let userDefaults = NSUserDefaults.standardUserDefaults()
        self.formatter.language = Languages.languageValues[userDefaults.stringForKey("Language")!]!
        self.formatter.custom = Nusach.nusachValues[userDefaults.stringForKey("Nusach")!]!
        if let adjustedDay = dayOfSefira {
            self.setSefiraText(adjustedDay, formatter: formatter)
        } else {
            self.setSefiraText(1, formatter: formatter)
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func setSefiraText(dayOfSefira: Int, formatter: KCSefiraFormatter) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let prayerDefaults = userDefaults.arrayForKey("Options") as! [String]
        var prayers: KCSefiraPrayerAddition = KCSefiraPrayerAddition()
        for option in prayerDefaults {
            prayers = prayers.union(Options.optionValues[option]!)
        }
        
        let attributedString = formatter.countStringFromInteger(dayOfSefira, withPrayers: prayers)
        self.sefriahTextLabel.setAttributedText(attributedString)
    }
}
