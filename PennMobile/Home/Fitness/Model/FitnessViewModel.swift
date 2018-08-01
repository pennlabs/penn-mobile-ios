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
    
    func getFacility(for indexPath: IndexPath) -> FitnessSchedule? {
        return FitnessFacilityData.shared.getSchedule(for: facilities[indexPath.row])
    }
}
