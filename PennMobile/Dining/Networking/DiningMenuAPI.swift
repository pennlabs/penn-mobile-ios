//
//  DiningMenuAPI.swift
//  PennMobile
//
//  Created by Dominic on 7/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

class DiningMenuAPI: Requestable {
    
    static let instance = DiningMenuAPI()
    
    let diningMenuUrl = "https://api.pennlabs.org/dining/daily_menu/"
    
    func fetchDiningMenu(for venue: DiningVenueName, _ completion: @escaping (_ success: Bool) -> Void) {
        getRequest(url: (diningMenuUrl + String(venue.getID()))) { (dictionary, error, statusCode) in
            if dictionary == nil {
                completion(false)
                return
            }
            let json = JSON(dictionary!)
            let success = DiningMenuData.shared.loadMenusForSingleVenue(with: json, for: venue)
            completion(success)
        }
    }
}

extension DiningMenuData {
    
    fileprivate func loadMenusForSingleVenue(with json: JSON, for venue: DiningVenueName) -> Bool {

        let decoder = JSONDecoder()
        
        do {
            let decodedMenu = try decoder.decode(DiningMenuDocument.self, from: json.rawData())
            self.load(menu: decodedMenu.document, for: venue)
        } catch {
            print(error)
            return false
        }

        return true
    }
}
