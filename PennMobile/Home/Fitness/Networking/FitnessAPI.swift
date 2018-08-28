//
//  FitnessAPI.swift
//  PennMobile
//
//  Created by raven on 7/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

class FitnessAPI: Requestable {
    
    static let instance = FitnessAPI()
    
    let fitnessScheduleUrl = "https://api.pennlabs.org/fitness/schedule"
    
    func fetchFitnessHours(_ completion: @escaping (_ success: Bool) -> Void) {
        getRequest(url: fitnessScheduleUrl) { (dictionary) in
            if dictionary == nil {
                completion(false)
                return
            }
            let json = JSON(dictionary!)
            let success = FitnessFacilityData.shared.loadHoursForFacilities(with: json)
            completion(success)
        }
    }
}

extension FitnessFacilityData {
    
    fileprivate func loadHoursForFacilities(with json: JSON) -> Bool {
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let decodedSchedules = try decoder.decode(FitnessSchedules.self, from: json.rawData())
            self.load(inputSchedules: decodedSchedules)
        } catch {
            print(error)
            return false
        }
        
        return true
    }
}
