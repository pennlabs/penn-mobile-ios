//
//  FitnessViewModel.swift
//  PennMobile
//
//  Created by raven on 7/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class FitnessViewModel: NSObject {

    let facilities: [FitnessFacilityName] = FitnessFacilityName.all

    var pottruckFacilities: [FitnessFacilityName] {
        get {
            return [.pottruck, .sheerr, .rockwell, .climbing, .membership]
        }
    }

    var otherFacilities: [FitnessFacilityName] {
        get {
            return [.fox, .ringe]
        }
    }

    func getPottruckFacility(for row: Int) -> FitnessSchedule? {
        return FitnessFacilityData.shared.getScheduleForToday(for: pottruckFacilities[row])
    }

    func getOtherFacility(for row: Int) -> FitnessSchedule? {
        return FitnessFacilityData.shared.getScheduleForToday(for: otherFacilities[row])
    }
}
