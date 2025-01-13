//
//  RefactorDiningAPI.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 1/13/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//
import Foundation
import PennMobileShared
import HeapModule

public final class RefactorDiningAPI: Sendable {
    public static let instance = RefactorDiningAPI()
    
    let venueUrl = URL(string: "https://pennmobile.org/api/dining/venues/")!
    let menuUrl = URL(string: "https://pennmobile.org/api/dining/menus/")!
    
    
    public func getDiningHalls() async -> Result<[RefactorDiningHall], Error> {
        guard let (venueData, _) = try? await URLSession.shared.data(from: venueUrl), let (menuData, _) = try? await URLSession.shared.data(from: menuUrl) else {
            return .failure(NetworkingError.serverError)
        }
        
        let json = JSONDecoder()
        json.keyDecodingStrategy = .convertFromSnakeCase
        
        // since one of the models has a field that doesn't exist in the data, we're going to artificially add it to the data so that it can be decoded
        var preprocessedVenueData: [RefactorVenueAPIDiningHall] = []
        var preprocessedMenuData: [RefactorMenuAPIMeal] = []
        do {
            
            preprocessedVenueData = try json.decode([RefactorVenueAPIDiningHall].self, from: venueData)
            
            preprocessedMenuData = try json.decode([RefactorMenuAPIMeal].self, from: menuData)
        } catch {
            print(error)
            return .failure(error)
        }
        
        let halls = getLinkedHallData(venueData: preprocessedVenueData, menuData: preprocessedMenuData)
        if halls.isEmpty {
            print("Probably a mismatch between APIs")
            return .failure(NetworkingError.serverError)
        }
        
        return .success(halls)
        
        
        
    }
    
    func getLinkedHallData(venueData: [RefactorVenueAPIDiningHall], menuData: [RefactorMenuAPIMeal]) -> [RefactorDiningHall] {
        
        //convert venueData to an array of meals (menuData already decoded into this type), sorted with the same comparison as the menuAPI data
        var modVenueData = venueData
        
        var allVenueMeals: [VenueAPIMeal] = []
        
        //give each meal an the venueId of it's parent venue
        for i in 0..<modVenueData.count {
            for j in 0..<modVenueData[i].schedule.count {
                for k in 0..<modVenueData[i].schedule[j].meals.count {
                    modVenueData[i].schedule[j].meals[k].venueId = modVenueData[i].id
                    allVenueMeals.append(modVenueData[i].schedule[j].meals[k])
                }
            }
        }
        
        var venueMeals: Heap<VenueAPIMeal> = Heap(allVenueMeals)
        var menuMeals: Heap<RefactorMenuAPIMeal> = Heap(menuData)
        
        var finalMeals: [RefactorDiningMeal] = []
        
        while (!venueMeals.isEmpty && !menuMeals.isEmpty) {
            
            let venueMin = venueMeals.min!
            let menuMin = menuMeals.min!
            
            //in the case where the two meals are equal, combine them and remove from both heaps.s
            if venueMin.venueId == menuMin.venue.venueId && venueMin.startTime == menuMin.startTime && venueMin.endTime == menuMin.endTime {
                let venueMeal = venueMeals.removeMin()
                let menuMeal = menuMeals.removeMin()
                let combined = combineMeals(venueMeal: venueMeal, menuMeal: menuMeal)
                finalMeals.append(combined)
                
            } else {
                // venueMin < menuMin (could implement an interface/superclass but for a one-time use felt it unnecessary)
                // remove the lesser of the two minimums until they both are empty in the case where we didn't remove them both
                if (venueMin.venueId ?? -1 < menuMin.venue.venueId || venueMin.startTime < menuMin.startTime) {
                    let _ = venueMeals.removeMin()
                } else {
                    let _ = menuMeals.removeMin()
                }
            }
        }
        
        
        var finalHalls: [RefactorDiningHall] = []
        
        for venue in venueData {
            let meals = finalMeals.filter { el in
                el.venueId == venue.id
            }
            
            finalHalls.append(RefactorDiningHall(id: venue.id, name: venue.name, address: venue.address, meals: meals, imageUrl: venue.imageUrl))
        }
        
        return finalHalls
        
    }
    
    func combineMeals(venueMeal: VenueAPIMeal, menuMeal: RefactorMenuAPIMeal) -> RefactorDiningMeal {
        return RefactorDiningMeal(id: menuMeal.id, venueId: venueMeal.venueId ?? -1, stations: menuMeal.stations, startTime: venueMeal.startTime, endTime: venueMeal.endTime, message: venueMeal.message, service: menuMeal.service)
    }
    
}
