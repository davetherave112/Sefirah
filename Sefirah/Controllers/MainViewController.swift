//
//  ViewController.swift
//  Sefirah
//
//  Created by Josh Siegel on 4/24/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import UIKit
import KosherCocoa
import KDCircularProgress
import CoreLocation

class MainViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var sefiraDay: UILabel!
    //@IBOutlet weak var progressView: CircleProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var dayOfSefira: Int?
    let locationManager = CLLocationManager()
    var formatter = KCSefiraFormatter()
    var sefiraDayNumber: SefiraDay?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        self.sefiraDayNumber = SefiraDay(locationManager: locationManager)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        formatter = KCSefiraFormatter()

        sefiraDayNumber!.getLocation()
        
        formatter.language = Languages.languageValues[userDefaults.stringForKey("Language")!]!
        formatter.custom = Nusach.nusachValues[userDefaults.stringForKey("Nusach")!]!
        
        let lastRecordedDay = NSUserDefaults.standardUserDefaults().integerForKey("LastRecordedDay")
        self.setSefiraText(lastRecordedDay)
        self.createProgressCircle(lastRecordedDay)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: self.sefiraDay.frame.maxY + 50)
        
        self.sefiraDay.sizeToFit()
                
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = locations.last!.coordinate
        locationManager.stopUpdatingLocation()
        self.dayOfSefira = sefiraDayNumber!.setAdjustedSefiraDay(locValue)
        NSUserDefaults.standardUserDefaults().setInteger(dayOfSefira!, forKey: "LastRecordedDay")
        setSefiraText(dayOfSefira!)
        createProgressCircle(dayOfSefira!)
        
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // Recover from no location services available
        let lastRecordedDay = NSUserDefaults.standardUserDefaults().integerForKey("LastRecordedDay")
        if lastRecordedDay > 0 {
            setSefiraText(lastRecordedDay)
            createProgressCircle(lastRecordedDay)
        }
        print(error)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func setSefiraText(dayOfSefira: Int) {
        let prayerOptions = NSUserDefaults.standardUserDefaults().arrayForKey("Options")!
        var prayers: KCSefiraPrayerAddition = KCSefiraPrayerAddition()
        for option in prayerOptions {
            prayers = prayers.union(Options.optionValues[option as! String]!)
        }
        
        self.sefiraDay.attributedText = formatter.countStringFromInteger(dayOfSefira, withPrayers: prayers)
        self.progressLabel.text = "\(dayOfSefira)"
    }

    func createProgressCircle(dayOfSefira: Int) {
        let progress = KDCircularProgress(frame: CGRectMake(0, 0, circleView.frame.size.width, circleView.frame.size.height))
        progress.translatesAutoresizingMaskIntoConstraints = false
        circleView.addSubview(progress)
        let constraint1 = NSLayoutConstraint(item: self.circleView, attribute: .Leading, relatedBy: .Equal, toItem: progress, attribute: .Leading, multiplier: 1.0, constant: 0)
        let constraint2 = NSLayoutConstraint(item: self.circleView, attribute: .Trailing, relatedBy: .Equal, toItem: progress, attribute: .Trailing, multiplier: 1.0, constant: 0)
        let constraint3 = NSLayoutConstraint(item: self.circleView, attribute: .Top, relatedBy: .Equal, toItem: progress, attribute: .Top, multiplier: 1.0, constant: 0)
        let constraint4 = NSLayoutConstraint(item: self.circleView, attribute: .Bottom, relatedBy: .Equal, toItem: progress, attribute: .Bottom, multiplier: 1.0, constant: 0)
        self.circleView.addConstraints([constraint1, constraint2, constraint3, constraint4])
        progress.startAngle = -90
        progress.progressThickness = 0.2
        progress.trackThickness = 0.4
        progress.clockwise = true
        progress.center = view.center
        progress.gradientRotateSpeed = 2
        progress.roundedCorners = true
        progress.glowMode = .Forward
        progress.angle = 360.0 * Double(dayOfSefira)/100.0
        progress.trackColor = UIColor(rgba: "#0e386c")
        progress.setColors(UIColor(rgba: "#c19f69"))
    }

}

