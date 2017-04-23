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
    var displayedAlert: Bool = false
    var wasOwnView: Bool = false
    
    @IBAction func languageSettings() {
        self.presentController(withName: "LanguagesController", context: nil)
    }
    
    @IBAction func prayerOptions() {
        self.presentController(withName: "PrayerOptionsController", context: nil)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.formatter = KCSefiraFormatter()
        

    }
    
    func showPopup() {

        let action = WKAlertAction(title: "Cancel", style: WKAlertActionStyle.cancel, handler: {
            if self.wasOwnView {
                self.displayedAlert = true;
                self.dismiss();
            }
        })
        self.presentAlert(withTitle: "Error", message: "Unauthorized GPS Access. Please open Sefirah on your iPhone and tap on current location.", preferredStyle: .actionSheet, actions: [action])
    }
    
    

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        let dayOfSefira = adjustedDay.sefiraDate
        let userDefaults = UserDefaults.standard
        self.formatter.language = Languages.languageValues[userDefaults.string(forKey: "Language")!]!
        self.formatter.custom = Nusach.nusachValues[userDefaults.string(forKey: "Nusach")!]!
        if let adjustedDay = dayOfSefira {
            self.setSefiraText(adjustedDay, formatter: formatter)
        } else {
            self.setSefiraText(1, formatter: formatter)
        }
        
        let success = SefiraDayWatch.sharedInstance.getLocation()
        if !success && (!self.displayedAlert || !self.wasOwnView) {
            self.showPopup()
        }
        
    }
    
    override func didAppear() {
        super.didAppear()
        
        if !self.wasOwnView {
            self.wasOwnView = true
        } else {
            self.displayedAlert = false
            self.wasOwnView = false
        }
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        let success = SefiraDayWatch.sharedInstance.getLocation()
        if !success && !self.wasOwnView {
            self.showPopup()
        }
        
        
    }


    func setSefiraText(_ dayOfSefira: Int, formatter: KCSefiraFormatter) {
        let userDefaults = UserDefaults.standard
        let prayerDefaults = userDefaults.array(forKey: "Options") as! [String]
        var prayers: KCSefiraPrayerAddition = KCSefiraPrayerAddition()
        for option in prayerDefaults {
            prayers = prayers.union(Options.optionValues[option]!)
        }
        
        let attributedString = formatter.countString(from: dayOfSefira, withPrayers: prayers)
        self.sefriahTextLabel.setAttributedText(attributedString)
    }
}
