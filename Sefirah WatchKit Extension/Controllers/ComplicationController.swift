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
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(dateOfSixteenNissanForYear(of: Date()) as Date)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        let startDate = dateOfSixteenNissanForYear(of: Date())
        let endDate = startDate.addingTimeInterval(60*60*24*50)
        handler(endDate as Date)
    }
    
    func dateOfSixteenNissanForYear(of: Date) -> NSDate {
        var hebrewCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.hebrew)
        var hebrewYearInDate = hebrewCalendar?.years(in: of)
        
        return NSDate(day: 16, month: 8, year: UInt(hebrewYearInDate!), andCalendar: hebrewCalendar! as Calendar!)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: (@escaping (CLKComplicationTimelineEntry?) -> Void)) {
        
        if let entry = self.getTemplate(complication) {
            handler(entry)
        } else {
            handler(nil)
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: (@escaping ([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries prior to the given date
        var entries: [CLKComplicationTimelineEntry] = []
        let beforeDate = self.getDateOnly(date)
        if let location = SefiraDayWatch.sharedInstance.lastRecordedLocation {
            for n in 0..<limit {
                let calendar = KCZmanimCalendar(location: location)
                calendar?.workingDate = beforeDate.addingTimeInterval(-1 * (60*60*24) * Double(n))
                //beforeDate = calendar.workingDate
                let tzeis = calendar?.tzais()
                let entry = self.getTemplate(complication, date: tzeis!, offset: 1)
                entries.append(entry!)
            }
            handler(entries.reversed())
        } else {
            handler(nil)
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: (@escaping ([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        var entries: [CLKComplicationTimelineEntry] = []
        let afterDate = self.getDateOnly(date)
        if let location = SefiraDayWatch.sharedInstance.lastRecordedLocation {
            for n in 0..<limit {
                let calendar = KCZmanimCalendar(location: location)
                calendar?.workingDate = afterDate.addingTimeInterval(Double(n)*60*60*24)
                //afterDate = calendar.workingDate
                let tzeis = calendar?.tzais()
                let entry = self.getTemplate(complication, date: tzeis!, offset: 1)
                entries.append(entry!)
            }
            handler(entries)
        } else {
            handler(nil)
        }
        
    }
    
    // MARK: - Update Scheduling
    
    func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void) {
        // Call the handler with the date when you would next like to be given the opportunity to update your complication content
        handler(Date(timeIntervalSinceNow: 60*60*12));
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        var template: CLKComplicationTemplate? = nil
        switch complication.family {
        case .modularSmall:
            let modularTemplate = CLKComplicationTemplateModularSmallRingText()
            modularTemplate.textProvider = CLKSimpleTextProvider(text: "--")
            modularTemplate.fillFraction = 0
            modularTemplate.ringStyle = CLKComplicationRingStyle.closed
            template = modularTemplate
        case .modularLarge:
            template = nil
        case .utilitarianSmall:
            let modularTemplate = CLKComplicationTemplateUtilitarianSmallRingText()
            modularTemplate.textProvider = CLKSimpleTextProvider(text: "--")
            modularTemplate.fillFraction = 0
            modularTemplate.ringStyle = CLKComplicationRingStyle.closed
            template = modularTemplate
        case .utilitarianLarge:
            template = nil
        case .circularSmall:
            let modularTemplate = CLKComplicationTemplateCircularSmallRingText()
            modularTemplate.textProvider = CLKSimpleTextProvider(text: "--")
            modularTemplate.fillFraction = 0
            modularTemplate.ringStyle = CLKComplicationRingStyle.closed
            template = modularTemplate
        default:
            template = nil
        }
        handler(template)
    }
    
    func getCurrentDay(_ offset: Int) -> String {
        // This would be used to retrieve current day
        // for display on the watch. For testing, this always returns a
        // constant.
        
        //return String(KCSefiratHaomerCalculator.dayOfSefira())
        
        let dayOfSefira = KCSefiratHaomerCalculator.dayOfSefira(for: Date())
        if dayOfSefira > 0 {
            return String(dayOfSefira + offset)
        } else {
            return "--"
        }
    }
    
    func getDifferentDay(_ date: Date) -> Int {
        return KCSefiratHaomerCalculator.dayOfSefira(for: date)
    }
        
    func getTemplate(_ complication: CLKComplication, date: Date = Date(), offset: Int = 0) -> CLKComplicationTimelineEntry? {
        let currentDay = getDifferentDay(date)
        if complication.family == .circularSmall {
            let template = CLKComplicationTemplateCircularSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "\(currentDay + offset)")
            template.textProvider.tintColor = UIColor(rgba: "#ab8454")
            template.ringStyle = CLKComplicationRingStyle.closed
            template.tintColor = UIColor(rgba: "#ab8454")
            template.fillFraction = getCurrentProgress()
            let timelineEntry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            return timelineEntry
        } else if complication.family == .utilitarianSmall {
            let template = CLKComplicationTemplateUtilitarianSmallRingText()
            let textProvider = CLKSimpleTextProvider(text: "\(currentDay + offset)")
            textProvider.tintColor = UIColor(rgba: "#ab8454")
            template.textProvider = textProvider
            template.ringStyle = CLKComplicationRingStyle.closed
            template.tintColor = UIColor(rgba: "#ab8454")
            template.fillFraction = getCurrentProgress()
            let timelineEntry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            return timelineEntry
        } else if complication.family == .modularSmall {
            let template = CLKComplicationTemplateModularSmallRingText()
            let textProvider = CLKSimpleTextProvider(text: "\(currentDay + offset)")
            textProvider.tintColor = UIColor(rgba: "#ab8454")
            template.textProvider = textProvider
            template.ringStyle = CLKComplicationRingStyle.closed
            template.tintColor = UIColor(rgba: "#ab8454")
            template.fillFraction = getCurrentProgress()
            let timelineEntry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
            return timelineEntry
        } else {
            return nil
        }
    }

    func getDateOnly(_ date: Date) -> Date {
        let flags: NSCalendar.Unit = [.year, .month, .day]
        let components = (Calendar.current as NSCalendar).components(flags, from: date)
        let dateOnly = Calendar.current.date(from: components)
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
