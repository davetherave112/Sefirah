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

class ViewController: UIViewController {

    @IBOutlet weak var sefiraDay: UILabel!
    @IBOutlet weak var progressView: CircleProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let dayOfSefira = KCSefiratHaomerCalculator.dayOfSefira()
        let formatter = KCSefiraFormatter()
        formatter.language = KCSefiraLanguage.LanguageEnglish
        self.sefiraDay.text = formatter.countStringFromInteger(dayOfSefira)
        self.progressLabel.text = "\(dayOfSefira)"
        
        let progress = Double(dayOfSefira)/100.0
        
        self.progressView.setProgress(progress, animated: true)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

