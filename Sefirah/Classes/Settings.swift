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
    case fifteenBefore = -15.0
    case thirtyBefore = -30.0
    case fortyFiveBefore = -45.0
    case hourBefore = -60.0
    case fifteenAfter = 15.0
    case thirtyAfter = 30.0
    case fortyFiveAfter = 45.0
    case hourAfter = 60.0
    case atTzeis = 0.0
    
    var description: String {
        switch self {
        case .atTzeis:
            return "0 Minutes (At Tzeis)"
        case .fifteenBefore:
            return "15 Minutes"
        case .thirtyBefore:
            return "30 Minutes"
        case .fortyFiveBefore:
            return "45 Minutes"
        case .hourBefore:
            return "1 Hour"
        case .fifteenAfter:
            return "15 Minutes"
        case .thirtyAfter:
            return "30 Minutes"
        case .fortyFiveAfter:
            return "45 Minutes"
        case .hourAfter:
            return "1 Hour"
        }
    }

    var notificationName: String {
        switch self {
        case .atTzeis:
            return "tzeis-0"
        case .fifteenBefore:
            return "tzeis-15-before"
        case .thirtyBefore:
            return "tzeis-30-before"
        case .fortyFiveBefore:
            return "tzeis-45-before"
        case .hourBefore:
            return "tzeis-hour-before"
        case .fifteenAfter:
            return "tzeis-15-after"
        case .thirtyAfter:
            return "tzeis-30-after"
        case .fortyFiveAfter:
            return "tzeis-45-after"
        case .hourAfter:
            return "tzeis-hour-after"
        }
    }
    
    static let allValues = [fifteenBefore, thirtyBefore, fortyFiveBefore, hourBefore, fifteenAfter, thirtyAfter, fortyFiveAfter, hourAfter, atTzeis]
    static let beforeValues = [.atTzeis, fifteenBefore, thirtyBefore, fortyFiveBefore, hourBefore]
    static let afterValues = [fifteenAfter, thirtyAfter, fortyFiveAfter, hourAfter]
}

enum Languages: String {
    case English = "English"
    case Hebrew = "Hebrew"
    
    static let allValues = [English, Hebrew]
    static let languageValues = [English.rawValue: KCSefiraLanguage.languageEnglish, Hebrew.rawValue: KCSefiraLanguage.languageHebrew]
}

enum Nusach: String {
    case Ashkenaz = "Ashkenaz"
    case Sefard = "Sefard"
    case Sephardic = "Edot Hamizrach"
    
    static let allValues = [Ashkenaz, Sefard, Sephardic]
    static let nusachValues = [Ashkenaz.rawValue: KCSefiraCustom.ashkenaz, Sefard.rawValue: .sefard, Sephardic.rawValue: .sephardic]
}

enum Options: String {
    case Aleinu = "Aleinu"
    case Ana = "Ana"
    case Beracha = "Beracha"
    case Harachaman = "Harachaman"
    case Lamenatzaiach = "Lamenatzaiach"
    case LeshaimYichud = "Leshaim Yichud"
    case Ribono = "Ribono"
    
    static let allValues = [LeshaimYichud, Beracha, Harachaman, Lamenatzaiach, Ana, Ribono, Aleinu]
    static let optionValues = [Aleinu.rawValue: KCSefiraPrayerAddition.aleinu,
                               Ana.rawValue: KCSefiraPrayerAddition.ana,
                               Beracha.rawValue: KCSefiraPrayerAddition.beracha,
                               Harachaman.rawValue: KCSefiraPrayerAddition.harachaman,
                               Lamenatzaiach.rawValue: KCSefiraPrayerAddition.lamenatzaiach,
                               LeshaimYichud.rawValue: KCSefiraPrayerAddition.leshaimYichud,
                               Ribono.rawValue: KCSefiraPrayerAddition.ribono]
}
