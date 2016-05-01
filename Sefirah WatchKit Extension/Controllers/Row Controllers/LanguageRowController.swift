//
//  LanguageRowController.swift
//  Sefirah
//
//  Created by Josh Siegel on 5/1/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import WatchKit

class LanguageRowController: NSObject {
    @IBOutlet var separator: WKInterfaceSeparator!
    @IBOutlet var languageLabel: WKInterfaceLabel!
    @IBOutlet var checkImage: WKInterfaceImage!
    
    var language: Languages? {
        didSet {
            if let language = language {
                languageLabel.setText(language.rawValue)
                let selectedLanguage = Languages(rawValue: NSUserDefaults.standardUserDefaults().stringForKey("Language")!)
                if selectedLanguage == language {
                    self.checkImage.setHidden(false)
                }
            }
        }
    }
}
