//
//  PrivacyPreference.swift
//  PennMobile
//
//  Created by Dominic Holmes on 12/27/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

struct PrivacyPreference: Codable, Hashable {
    // Default to permission not being given
    var decision: Bool = false
    let option: PrivacyOption
}

enum PrivacyOption: String, Codable, CaseIterable {
    case anonymizedCourseEnrollment
    case anonymizedDiningTransactions
    case collegeHouse
    case personalInformation
}
