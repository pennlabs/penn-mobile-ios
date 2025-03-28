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
    
    let venueUrlString = "https://pennmobile.org/api/dining/venues/"
    let menuUrlString = "https://pennmobile.org/api/dining/menus/"
    
    
    public func getDiningHalls() async -> Result<[RefactorDiningHall], Error> {
        guard let (venueData, _) = try? await URLSession.shared.data(from: URL(string: venueUrlString)!) else {
            return .failure(NetworkingError.serverError)
        }
        
        let json = JSONDecoder()
        json.keyDecodingStrategy = .convertFromSnakeCase
        
        // since one of the models has a field that doesn't exist in the data, we're going to artificially add it to the data so that it can be decoded
        var preprocessedVenueData: [RefactorVenueAPIDiningHall] = []
        var preprocessedMenuData: [RefactorMenuAPIMeal] = []
        
        let date = DateFormatter()
        date.dateFormat = "yyyy-MM-dd"
        for i in 0..<7 {
            guard let (menuData, _) = try? await URLSession.shared.data(from: URL(string: menuUrlString + date.string(from: Calendar.current.date(byAdding: .day, value: i, to: Date.now.localTime)!))!) else {
                return .failure(NetworkingError.serverError)
            }
            
            do {
                let newMeals = try json.decode([RefactorMenuAPIMeal].self, from: menuData)
                preprocessedMenuData.append(contentsOf: newMeals)
            } catch {
                print(error)
                return .failure(error)
            }
        }
        
        do {
            preprocessedVenueData = try json.decode([RefactorVenueAPIDiningHall].self, from: venueData)
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
    
    
    //This function is COOL. Linking the values together using a heap. Notable change that may result in errors down the road (due to duplicate ids)
    //The function had to be modified to include partial menus. That is, when a meal existed on one endpoint but not another we previously discarded it,
    //However I had to change it so that it includes a menu that contains some relevant details but not all, replacing the other fields with a placeholder.
    func getLinkedHallData(venueData: [RefactorVenueAPIDiningHall], menuData: [RefactorMenuAPIMeal]) -> [RefactorDiningHall] {
        
        //convert venueData to an array of meals (menuData already decoded into this type), sorted with the same comparison as the menuAPI data
        var modVenueData = venueData
        
        var allVenueMeals: [VenueAPIMeal] = []
        
        // give each meal an the venueId of its parent venue
        // w efficiency
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
        
        while (!venueMeals.isEmpty || !menuMeals.isEmpty) {
            
            let venueMin: VenueAPIMeal? = venueMeals.min
            let menuMin: RefactorMenuAPIMeal? = menuMeals.min
            
            if let venueMin = venueMeals.min, let menuMin = menuMeals.min {
                //The same meal
                if venueMin.venueId == menuMin.venue.venueId && venueMin.startTime == menuMin.startTime && venueMin.endTime == menuMin.endTime {
                    let venueMeal = venueMeals.removeMin()
                    let menuMeal = menuMeals.removeMin()
                    let combined = combineMeals(venueMeal: venueMeal, menuMeal: menuMeal)
                    finalMeals.append(combined)
                } else {
                    //different meals but both still non-null
                    if (venueMin.venueId ?? -1 < menuMin.venue.venueId || (venueMin.venueId ?? -1 == menuMin.venue.venueId && venueMin.startTime < menuMin.startTime)) {
                        let meal = venueMeals.removeMin()
                        finalMeals.append(RefactorDiningMeal(id: -1, venueId: meal.venueId ?? -1, stations: [], startTime: meal.startTime, endTime: meal.endTime, message: meal.message, service: meal.label))
                    } else {
                        let meal = menuMeals.removeMin()
                        finalMeals.append(RefactorDiningMeal(id: meal.id, venueId: meal.venue.venueId, stations: meal.stations, startTime: meal.startTime, endTime: meal.endTime, message: "", service: meal.service))
                    }
                }
            } else {
                //one is null
                
                if venueMeals.min == nil {
                    //venueMeals is empty
                    let meal = menuMeals.removeMin()
                    finalMeals.append(RefactorDiningMeal(id: meal.id, venueId: meal.venue.venueId, stations: meal.stations, startTime: meal.startTime, endTime: meal.endTime, message: "", service: meal.service))
                    
                } else {
                    //menuMeals is empty
                    let meal = venueMeals.removeMin()
                    finalMeals.append(RefactorDiningMeal(id: -1, venueId: meal.venueId ?? -1, stations: [], startTime: meal.startTime, endTime: meal.endTime, message: meal.message, service: meal.label))
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
