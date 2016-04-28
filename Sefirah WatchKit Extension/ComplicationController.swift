//
//  ComplicationController.swift
//  Sefirah WatchKit Extension
//
//  Created by Josh Siegel on 4/24/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import ClockKit
import WatchKit
import KosherCocoa


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.Forward, .Backward])
    }
    
    func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.ShowOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        
        if let extensionDelegate = (WKExtension.sharedExtension().delegate as? ExtensionDelegate) {
            extensionDelegate.setupWCDelegate()
        }
        
        // Call the handler with the current timeline entry
        if complication.family == .CircularSmall {
            let template = CLKComplicationTemplateCircularSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: getCurrentDay())
            template.ringStyle = CLKComplicationRingStyle.Closed
            template.fillFraction = getCurrentProgress()
            let timelineEntry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
            handler(timelineEntry)
        } else if complication.family == .UtilitarianSmall {
            let template = CLKComplicationTemplateUtilitarianSmallRingText()
            let textProvider = CLKSimpleTextProvider(text: getCurrentDay())
            template.textProvider = textProvider
            template.ringStyle = CLKComplicationRingStyle.Closed
            template.fillFraction = getCurrentProgress()
            let timelineEntry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
            handler(timelineEntry)
        } else if complication.family == .ModularSmall {
            let template = CLKComplicationTemplateModularSmallRingText()
            let textProvider = CLKSimpleTextProvider(text: getCurrentDay())
            template.textProvider = textProvider
            template.ringStyle = CLKComplicationRingStyle.Closed
            template.fillFraction = getCurrentProgress()
            let timelineEntry = CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template)
            handler(timelineEntry)
        } else {
            handler(nil)
        }
        
        // Call the handler with the current timeline entry
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        handler(nil);
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(nil)
    }
    
    func getCurrentDay() -> String {
        // This would be used to retrieve current day
        // for display on the watch. For testing, this always returns a
        // constant.
        
        //return String(KCSefiratHaomerCalculator.dayOfSefira())
        
        if let extensionDelegate = (WKExtension.sharedExtension().delegate as? ExtensionDelegate) {
            return String(extensionDelegate.omerCount)
        } else {
            return "--"
        }
    }
    
    func getCurrentProgress() -> Float {
        if let extensionDelegate = (WKExtension.sharedExtension().delegate as? ExtensionDelegate) {
            return Float(extensionDelegate.omerCount)!/49
        } else {
            return 0
        }
    }
    
}
