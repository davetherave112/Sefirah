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
        handler(KCSefiratHaomerCalculator.dateOfSixteenNissanForYearOfDate(NSDate()))
    }
    
    func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
        let startDate = KCSefiratHaomerCalculator.dateOfSixteenNissanForYearOfDate(NSDate())
        let endDate = startDate.dateByAddingTimeInterval(60*60*24*50)
        handler(endDate)
    }
    
    func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.ShowOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {
        
        if let entry = self.getTemplate(complication) {
            handler(entry)
        } else {
            handler(nil)
        }
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries prior to the given date
        var entries: [CLKComplicationTimelineEntry] = []
        var beforeDate = self.getDateOnly(date)
        if let location = SefiraDayWatch.sharedInstance.lastRecordedLocation {
            for n in 0..<limit {
                let calendar = KCZmanimCalendar(location: location)
                calendar.workingDate = beforeDate.dateByAddingTimeInterval(-1 * (60*60*24) * Double(n))
                //beforeDate = calendar.workingDate
                let tzeis = calendar.tzais()
                let entry = self.getTemplate(complication, date: tzeis, offset: 1)
                entries.append(entry!)
            }
            handler(entries.reverse())
        } else {
            handler(nil)
        }
    }
    
    func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        var entries: [CLKComplicationTimelineEntry] = []
        var afterDate = self.getDateOnly(date)
        if let location = SefiraDayWatch.sharedInstance.lastRecordedLocation {
            for n in 0..<limit {
                let calendar = KCZmanimCalendar(location: location)
                calendar.workingDate = afterDate.dateByAddingTimeInterval(Double(n)*60*60*24)
                //afterDate = calendar.workingDate
                let tzeis = calendar.tzais()
                let entry = self.getTemplate(complication, date: tzeis, offset: 1)
                entries.append(entry!)
            }
            handler(entries)
        } else {
            handler(nil)
        }
        
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        handler(NSDate(timeIntervalSinceNow: 60*60*12));
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplateForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        var template: CLKComplicationTemplate? = nil
        switch complication.family {
        case .ModularSmall:
            let modularTemplate = CLKComplicationTemplateModularSmallRingText()
            modularTemplate.textProvider = CLKSimpleTextProvider(text: "--")
            modularTemplate.fillFraction = 0
            modularTemplate.ringStyle = CLKComplicationRingStyle.Closed
            template = modularTemplate
        case .ModularLarge:
            template = nil
        case .UtilitarianSmall:
            let modularTemplate = CLKComplicationTemplateUtilitarianSmallRingText()
            modularTemplate.textProvider = CLKSimpleTextProvider(text: "--")
            modularTemplate.fillFraction = 0
            modularTemplate.ringStyle = CLKComplicationRingStyle.Closed
            template = modularTemplate
        case .UtilitarianLarge:
            template = nil
        case .CircularSmall:
            let modularTemplate = CLKComplicationTemplateCircularSmallRingText()
            modularTemplate.textProvider = CLKSimpleTextProvider(text: "--")
            modularTemplate.fillFraction = 0
            modularTemplate.ringStyle = CLKComplicationRingStyle.Closed
            template = modularTemplate
        }
        handler(template)
    }
    
    func getCurrentDay(offset: Int) -> String {
        // This would be used to retrieve current day
        // for display on the watch. For testing, this always returns a
        // constant.
        
        //return String(KCSefiratHaomerCalculator.dayOfSefira())
        
        let dayOfSefira = KCSefiratHaomerCalculator.dayOfSefiraForDate(NSDate())
        if dayOfSefira > 0 {
            return String(dayOfSefira + offset)
        } else {
            return "--"
        }
    }
    
    func getDifferentDay(date: NSDate) -> Int {
        return KCSefiratHaomerCalculator.dayOfSefiraForDate(date)
    }
        
    func getTemplate(complication: CLKComplication, date: NSDate = NSDate(), offset: Int = 0) -> CLKComplicationTimelineEntry? {
        let currentDay = getDifferentDay(date)
        if complication.family == .CircularSmall {
            let template = CLKComplicationTemplateCircularSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "\(currentDay + offset)")
            template.textProvider.tintColor = UIColor(rgba: "#C19F69")
            template.ringStyle = CLKComplicationRingStyle.Closed
            template.tintColor = UIColor(rgba: "#C19F69")
            template.fillFraction = getCurrentProgress()
            let timelineEntry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            return timelineEntry
        } else if complication.family == .UtilitarianSmall {
            let template = CLKComplicationTemplateUtilitarianSmallRingText()
            let textProvider = CLKSimpleTextProvider(text: "\(currentDay + offset)")
            textProvider.tintColor = UIColor(rgba: "#C19F69")
            template.textProvider = textProvider
            template.ringStyle = CLKComplicationRingStyle.Closed
            template.tintColor = UIColor(rgba: "#C19F69")
            template.fillFraction = getCurrentProgress()
            let timelineEntry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            return timelineEntry
        } else if complication.family == .ModularSmall {
            let template = CLKComplicationTemplateModularSmallRingText()
            let textProvider = CLKSimpleTextProvider(text: "\(currentDay + offset)")
            textProvider.tintColor = UIColor(rgba: "#C19F69")
            template.textProvider = textProvider
            template.ringStyle = CLKComplicationRingStyle.Closed
            template.tintColor = UIColor(rgba: "#C19F69")
            template.fillFraction = getCurrentProgress()
            let timelineEntry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            return timelineEntry
        } else {
            return nil
        }
    }

    func getDateOnly(date: NSDate) -> NSDate {
        let flags: NSCalendarUnit = [.Year, .Month, .Day]
        let components = NSCalendar.currentCalendar().components(flags, fromDate: date)
        let dateOnly = NSCalendar.currentCalendar().dateFromComponents(components)
        return dateOnly!
    }

    func getCurrentProgress() -> Float {
        if let dayOfSefira = SefiraDayWatch.sharedInstance.sefiraDate {
            return Float(dayOfSefira)/50
        } else {
            return 0
        }
    }
    
}
