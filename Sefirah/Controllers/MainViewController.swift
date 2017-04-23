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
    var formatter = KCSefiraFormatter()
    let adjustedDay = SefiraDay.sharedInstance
    let locationManager = SefiraDay.sharedInstance.locationManager
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userDefaults = UserDefaults.standard
        
        formatter = KCSefiraFormatter()

        let success = adjustedDay.getLocation()
        if !success {
            let alert = UIAlertController(title: "Error", message: "Unauthorized GPS Access. Please open Sefirah on your iPhone and tap on current location.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        formatter.language = Languages.languageValues[userDefaults.string(forKey: "Language")!]!
        formatter.custom = Nusach.nusachValues[userDefaults.string(forKey: "Nusach")!]!
        
        let lastRecordedDay = UserDefaults.standard.integer(forKey: "LastRecordedDay")
        self.setSefiraText(lastRecordedDay)
        self.createProgressCircle(lastRecordedDay)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: self.sefiraDay.frame.maxY + 50)
        
        self.sefiraDay.sizeToFit()
                
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = locations.last!.coordinate
        locationManager.stopUpdatingLocation()
        
        self.dayOfSefira = adjustedDay.setAdjustedSefiraDay(locValue)
        UserDefaults.standard.set(dayOfSefira!, forKey: "LastRecordedDay")
        setSefiraText(dayOfSefira!)
        createProgressCircle(dayOfSefira!)
        
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Recover from no location services available
        let lastRecordedDay = UserDefaults.standard.integer(forKey: "LastRecordedDay")
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

    
    func setSefiraText(_ dayOfSefira: Int) {
        let prayerOptions = UserDefaults.standard.array(forKey: "Options")!
        var prayers: KCSefiraPrayerAddition = KCSefiraPrayerAddition()
        for option in prayerOptions {
            prayers = prayers.union(Options.optionValues[option as! String]!)
        }
        
        self.sefiraDay.attributedText = formatter.countString(from: dayOfSefira, withPrayers: prayers)
        self.progressLabel.text = "\(dayOfSefira)"
    }

    func createProgressCircle(_ dayOfSefira: Int) {
        let progress = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: circleView.frame.size.width, height: circleView.frame.size.height))
        progress.translatesAutoresizingMaskIntoConstraints = false
        circleView.addSubview(progress)
        let constraint1 = NSLayoutConstraint(item: self.circleView, attribute: .leading, relatedBy: .equal, toItem: progress, attribute: .leading, multiplier: 1.0, constant: 0)
        let constraint2 = NSLayoutConstraint(item: self.circleView, attribute: .trailing, relatedBy: .equal, toItem: progress, attribute: .trailing, multiplier: 1.0, constant: 0)
        let constraint3 = NSLayoutConstraint(item: self.circleView, attribute: .top, relatedBy: .equal, toItem: progress, attribute: .top, multiplier: 1.0, constant: 0)
        let constraint4 = NSLayoutConstraint(item: self.circleView, attribute: .bottom, relatedBy: .equal, toItem: progress, attribute: .bottom, multiplier: 1.0, constant: 0)
        self.circleView.addConstraints([constraint1, constraint2, constraint3, constraint4])
        progress.startAngle = -90
        progress.progressThickness = 0.2
        progress.trackThickness = 0.4
        progress.clockwise = true
        progress.center = view.center
        progress.gradientRotateSpeed = 2
        progress.roundedCorners = true
        progress.glowMode = .forward
        progress.angle = 360.0 * Double(dayOfSefira)/100.0
        progress.trackColor = UIColor(rgba: "#161543")
        progress.set(colors: UIColor(rgba: "#ab8454"))
    }

}

