//
//  DiningMenuAPI.swift
//  PennMobile
//
//  Created by Dominic on 7/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import SwiftyJSON
import Foundation

class DiningMenuAPI: Requestable {
    
    static let instance = DiningMenuAPI()
    
    let diningMenuUrl = "https://api.pennlabs.org/dining/daily_menu/"
    
    func fetchDiningMenu(for venue: DiningVenueName, _ completion: @escaping (_ success: Bool) -> Void) {
        dump(venue.getID())
        getRequest(url: (diningMenuUrl + String(venue.getID()))) { (dictionary) in
            if dictionary == nil {
                completion(false)
                return
            }
            
            let json = JSON(dictionary!)
            let success = DiningMenuData.shared.loadMenusForSingleVenue(with: json)
            
            completion(success)
        }
    }
}

extension DiningMenuData {
    
    fileprivate func loadMenusForSingleVenue(with json: JSON) -> Bool {
        
        //dump(json)
        
        let decoder = JSONDecoder()
        
        do {
            let decodedMenu = try decoder.decode(DiningMenuDocument.self, from: json.rawData())
            dump(decodedMenu)
        } catch {
            print(error)
            print("Couldn't do it.")
        }
        
        //self.load(hours: hours, for: venueName)
        return true
    }
}
