//
//  FitnessFacilityData.swift
//  PennMobile
//
//  Created by dominic on 7/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

class FitnessFacilityData {
    
    static let shared = FitnessFacilityData()
    
    fileprivate var schedules = Dictionary<FitnessFacilityName, [FitnessSchedule]>()
    
    func load(inputSchedules: FitnessSchedules) {
        schedules = Dictionary<FitnessFacilityName, [FitnessSchedule]>()
        guard inputSchedules.schedules != nil else { return }
        
        for schedule in inputSchedules.schedules! {
            if schedule != nil {
                if schedules[schedule!.name] != nil {
                    schedules[schedule!.name]?.append(schedule!)
                } else {
                    schedules[schedule!.name] = [schedule!]
                }
            }
        }
    }
    
    func getScheduleForToday(for venue: FitnessFacilityName) -> FitnessSchedule? {
        guard schedules.keys.contains(venue) else { return nil }
        return schedules[venue]!.first(where: { (schedule) -> Bool in
            if schedule.start != nil {
                return schedule.start!.isToday
            }
            return false
        })
    }
    
    func getActiveFacilities() -> [FitnessFacilityName?] {
        var activeFacilities = [FitnessFacilityName]()
        
        for (name, schedule) in schedules {
            if schedule.contains(where: { (s) -> Bool in
                return (s.start != nil && s.start!.isToday)
            }) {
                activeFacilities.append(name)
            }
        }
        return activeFacilities
    }
    
    func clearSchedules() {
        schedules = Dictionary<FitnessFacilityName, [FitnessSchedule]>()
    }
}
