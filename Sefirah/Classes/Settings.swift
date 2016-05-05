//
//  Settings.swift
//  Sefirah
//
//  Created by Josh Siegel on 4/25/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import Foundation
import KosherCocoa


enum Tzeis: Double {
    case FifteenBefore = -15.0
    case ThirtyBefore = -30.0
    case FortyFiveBefore = -45.0
    case HourBefore = -60.0
    case FifteenAfter = 15.0
    case ThirtyAfter = 30.0
    case FortyFiveAfter = 45.0
    case HourAfter = 60.0
    case AtTzeis = 0.0
    
    var description: String {
        switch self {
        case .AtTzeis:
            return "0 Minutes (At Tzeis)"
        case .FifteenBefore:
            return "15 Minutes"
        case .ThirtyBefore:
            return "30 Minutes"
        case .FortyFiveBefore:
            return "45 Minutes"
        case .HourBefore:
            return "1 Hour"
        case .FifteenAfter:
            return "15 Minutes"
        case .ThirtyAfter:
            return "30 Minutes"
        case .FortyFiveAfter:
            return "45 Minutes"
        case .HourAfter:
            return "1 Hour"
        }
    }

    var notificationName: String {
        switch self {
        case .AtTzeis:
            return "tzeis-0"
        case .FifteenBefore:
            return "tzeis-15-before"
        case .ThirtyBefore:
            return "tzeis-30-before"
        case .FortyFiveBefore:
            return "tzeis-45-before"
        case .HourBefore:
            return "tzeis-hour-before"
        case .FifteenAfter:
            return "tzeis-15-after"
        case .ThirtyAfter:
            return "tzeis-30-after"
        case .FortyFiveAfter:
            return "tzeis-45-after"
        case .HourAfter:
            return "tzeis-hour-after"
        }
    }
    
    static let allValues = [FifteenBefore, ThirtyBefore, FortyFiveBefore, HourBefore, FifteenAfter, ThirtyAfter, FortyFiveAfter, HourAfter, AtTzeis]
    static let beforeValues = [.AtTzeis, FifteenBefore, ThirtyBefore, FortyFiveBefore, HourBefore]
    static let afterValues = [FifteenAfter, ThirtyAfter, FortyFiveAfter, HourAfter]
}

enum Languages: String {
    case English = "English"
    case Hebrew = "Hebrew"
    
    static let allValues = [English, Hebrew]
    static let languageValues = [English.rawValue: KCSefiraLanguage.LanguageEnglish, Hebrew.rawValue: KCSefiraLanguage.LanguageHebrew]
}

enum Nusach: String {
    case Ashkenaz = "Ashkenaz"
    case Sefard = "Sefard"
    case Sephardic = "Sephardic"
    
    static let allValues = [Ashkenaz, Sefard, Sephardic]
    static let nusachValues = [Ashkenaz.rawValue: KCSefiraCustom.Ashkenaz, Sefard.rawValue: .Sefard, Sephardic.rawValue: .Sephardic]
}

enum Options: String {
    case Aleinu = "Aleinu"
    case Ana = "Ana"
    case Beracha = "Beracha"
    case Harachaman = "Harachaman"
    case Lamenatzaiach = "Lamenatzaiach"
    case LeshaimYichud = "Leshaim Yichud"
    case Ribono = "Ribono"
    
    static let allValues = [Aleinu, Ana, Beracha, Harachaman, Lamenatzaiach, LeshaimYichud, Ribono]
    static let optionValues = [Aleinu.rawValue: KCSefiraPrayerAddition.Aleinu,
                               Ana.rawValue: KCSefiraPrayerAddition.Ana,
                               Beracha.rawValue: KCSefiraPrayerAddition.Beracha,
                               Harachaman.rawValue: KCSefiraPrayerAddition.Harachaman,
                               Lamenatzaiach.rawValue: KCSefiraPrayerAddition.Lamenatzaiach,
                               LeshaimYichud.rawValue: KCSefiraPrayerAddition.LeshaimYichud,
                               Ribono.rawValue: KCSefiraPrayerAddition.Ribono]
}