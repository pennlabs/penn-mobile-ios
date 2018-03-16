//
//  FlingNetworkManager.swift
//  PennMobile
//
//  Created by Josh Doman on 3/16/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SwiftyJSON

final class FlingNetworkManager: Requestable {
    static let instance = FlingNetworkManager()
    private init() {}
    
    fileprivate let flingUrl = "https://api.pennlabs.org/events/fling"
    
    func fetchPerformers(_ completion: @escaping (_ performers: [FlingPerformer]?) -> Void) {
        getRequest(url: flingUrl) { (dict) in
            var performers: [FlingPerformer]? = nil
            if let dict = dict {
                
            }
            completion(performers)
        }
    }
}
