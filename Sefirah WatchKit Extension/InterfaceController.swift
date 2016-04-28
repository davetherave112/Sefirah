//
//  InterfaceController.swift
//  Sefirah WatchKit Extension
//
//  Created by Josh Siegel on 4/24/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import WatchKit
import Foundation
import KosherCocoa

class InterfaceController: WKInterfaceController {
    
    var dayOfSefira: Int!
    
    //@IBOutlet weak var progressLabel: WKInterfaceLabel!
    @IBOutlet var progressImage: WKInterfaceImage!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        dayOfSefira = KCSefiratHaomerCalculator.dayOfSefira()
                
        //progressLabel.setText("\(dayOfSefira)")
        progressImage.setImageNamed("day\(dayOfSefira)")
        
        if let extensionDelegate = (WKExtension.sharedExtension().delegate as? ExtensionDelegate) {
            extensionDelegate.omerCount = String(dayOfSefira)
        }
        

    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
