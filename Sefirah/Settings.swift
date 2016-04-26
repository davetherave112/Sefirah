//
//  Settings.swift
//  Sefirah
//
//  Created by Josh Siegel on 4/25/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import Foundation
import KosherCocoa

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
    case LeshaimYichud = "LeshaimYichud"
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