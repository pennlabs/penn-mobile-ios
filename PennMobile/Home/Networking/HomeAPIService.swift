//
//  HomeAPIService.swift
//  PennMobile
//
//  Created by Josh Doman on 1/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

final class HomeAPIService {
    static let instance = HomeAPIService()

    func fetchModel(_ completion: @escaping ((HomeTableViewModel) -> Void)) {
        let group = DispatchGroup()
        
        let model = HomeTableViewModel()
        
        // Fetch HomeCellItem for all HomeItemTypes
        for item in HomeItemTypes.instance.getAllTypes() {
            group.enter()
            item.getHomeCellItem { item in
                item.forEach { i in
                    model.items.append(i)
                }
                
                group.leave()
            }
        }
        
        // Handle completion of model after it is done
        group.notify(queue: .main) {
            completion(model)
        }
    }
}
