//
//  HomeAPIService.swift
//  PennMobile
//
//  Created by Josh Doman on 1/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

final class HomeAPIService: Requestable {
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
        
        group.enter()
        var rankingDict: [String: Int] = [:]
        getRequestData(url: "https://pennmobile.org/api/penndata/order/") { (data, _, _) in
            guard let data = data else { group.leave(); return }
            for e in JSON(data).array ?? [JSON]() {
                if let cell = e["cell"].string, let ranking = e["rank"].int {
                    rankingDict[cell] = ranking
                }
            }
            
            group.leave()
        }
        
        // Handle completion of model after it is done
        group.notify(queue: .main) {
            if let homeItems = model.items as? [HomeCellItem] {
                model.items = homeItems.sorted(by: {rankingDict[$0.cellIdentifier] ?? -1 > rankingDict[$1.cellIdentifier] ?? -1})
            }
            
            completion(model)
        }
    }
}
