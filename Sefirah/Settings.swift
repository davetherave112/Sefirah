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
    static let languageValues = ["English": KCSefiraLanguage.LanguageEnglish, "Hebrew": KCSefiraLanguage.LanguageHebrew]
}