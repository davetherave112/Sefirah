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
import CoreLocation

class MainInterfaceController: WKInterfaceController, CLLocationManagerDelegate {
    
    //TODO: Add last recorded day to NSUserDefaults for use case when no location services available
    
    let adjustedDay = SefiraDayWatch.sharedInstance
    @IBOutlet var progressImage: WKInterfaceImage!
    var imageDisplayed: Bool = false
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        
        adjustedDay.locationManager.delegate = self
        adjustedDay.getLocation()
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = locations.last!.coordinate
        adjustedDay.locationManager.stopUpdatingLocation()
        adjustedDay.setAdjustedSefiraDay(locValue)
        if let dayOfSefira = adjustedDay.sefiraDate {
            self.setProgress(dayOfSefira, animate: true)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    
    func setProgress(dayOfSefira: Int, animate: Bool) {
        if animate && !imageDisplayed {
            let range = NSRange.init(location: 0, length: dayOfSefira + 1)
            self.progressImage.setImageNamed("day")
            progressImage.startAnimatingWithImagesInRange(range, duration: 0.7, repeatCount: 1)
            self.imageDisplayed = true
        } else {
            self.progressImage.setImageNamed("day\(dayOfSefira)")
        }
        
        if let extensionDelegate = (WKExtension.sharedExtension().delegate as? ExtensionDelegate) {
            extensionDelegate.omerCount = String(dayOfSefira)
        }
    }
    
    

}
