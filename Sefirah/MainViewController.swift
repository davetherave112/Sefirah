//
//  ViewController.swift
//  Sefirah
//
//  Created by Josh Siegel on 4/24/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import UIKit
import KosherCocoa
import CircleProgressView

class MainViewController: UIViewController {

    @IBOutlet weak var sefiraDay: UILabel!
    @IBOutlet weak var progressView: CircleProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        let dayOfSefira = KCSefiratHaomerCalculator.dayOfSefira()
        
        let formatter = KCSefiraFormatter()
        
        formatter.language = Languages.languageValues[userDefaults.stringForKey("Language")!]!
        formatter.custom = Nusach.nusachValues[userDefaults.stringForKey("Nusach")!]!
        
        let prayerOptions = userDefaults.arrayForKey("Options")!
        
        var prayers: KCSefiraPrayerAddition = KCSefiraPrayerAddition()
        for option in prayerOptions {
            prayers = prayers.union(Options.optionValues[option as! String]!)
        }

        self.sefiraDay.attributedText = formatter.countStringFromInteger(dayOfSefira, withPrayers: prayers)
        self.progressLabel.text = "\(dayOfSefira)"
        
        let progress = Double(dayOfSefira)/100.0
        
        self.progressView.setProgress(progress, animated: true)
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: self.sefiraDay.frame.maxY + 50)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

