//
//  FitnessViewModel.swift
//  PennMobile
//
//  Created by raven on 7/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class FitnessViewModel: NSObject {
    
    var facilities = [FitnessFacilityName?]()
    
    func getFacility(for indexPath: IndexPath) -> FitnessSchedule? {
        if (facilities.isEmpty) { facilities = FitnessFacilityData.shared.getActiveFacilities() }
        guard !facilities.isEmpty && indexPath.row < facilities.count && facilities[indexPath.row] != nil else { return nil }
        return FitnessFacilityData.shared.getScheduleForToday(for: facilities[indexPath.row]!)
    }
    
    func activeFacilities() -> [FitnessFacilityName?] {
        return FitnessFacilityData.shared.getActiveFacilities()
    }
}
