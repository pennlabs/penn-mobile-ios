//
//  CourseAlertSettingsPreference.swift
//  PennMobile
//
//  Created by Raunaq Singh on 11/8/20.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import Foundation

typealias PCAPreferences = Dictionary<String, Bool>

enum PCAOption: String, Codable {
    case alertsThroughPennMobile
    case alertsThroughEmail
    case classCloseAlerts
    
    static let visibleOptions: [PCAOption] = [.alertsThroughPennMobile]
    
    var cellTitle: String? {
        switch self {
        case .alertsThroughPennMobile: return "Send alerts through Penn Mobile"
        case .alertsThroughEmail: return "Send alerts through email"
        case .classCloseAlerts: return "Send notifications when classes close"
        }
    }
    
    var cellFooterDescription: String? {
        switch self {
        case .alertsThroughPennMobile: return "Alert notifications through Penn Mobile are faster than SMS alerts and can help unclutter your text messages."
        case .alertsThroughEmail: return "Alert notifications through Penn Mobile are faster than SMS alerts and can help unclutter your text messages."
        case .classCloseAlerts: return "Alert notifications through Penn Mobile are faster than SMS alerts and can help unclutter your text messages."
        }
    }
    
    var defaultValue: Bool {
        switch self {
            case .alertsThroughPennMobile: return false
            default: return false
        }
    }
}
