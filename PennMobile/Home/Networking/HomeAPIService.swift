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
    private init() {}

    func fetchModel(_ completion: @escaping (_ model: HomeTableViewModel?, _ error: NetworkingError?) -> Void) {
        let version = UserDefaults.standard.getAppVersion()
        var url = "http://localhost:5000/homepage?version=\(version)"
        if let sessionID = GSRUser.getSessionID() {
            url = "\(url)&sessionid=\(sessionID)"
        }
        if let courses = UserDefaults.standard.getCourses(), !courses.enrolledIn.isEmpty {
            if courses.taughtToday.hasUpcomingCourse {
                url = "\(url)&hasCourses=today"
            } else if !courses.taughtTomorrow.isEmpty {
                url = "\(url)&hasCourses=tomorrow"
            }
        }
    
        url = "\(url)&groupsEnabled=\(UserDefaults.standard.gsrGroupsEnabled())"
        
        
        
        OAuth2NetworkManager.instance.getAccessToken { (token) in
            // Make request without access token if one does not exist
            let url = URL(string: url)!
            var request = token != nil ? URLRequest(url: url, accessToken: token!) : URLRequest(url: url)
            
            // Add device ID to request to access data associated associated with device id (ex: favorite dining halls)
            let deviceID = getDeviceID()
            request.setValue(deviceID, forHTTPHeaderField: "X-Device-ID")
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error, (error as NSError).code == -1009 {
                    completion(nil, NetworkingError.noInternet)
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    completion(nil, NetworkingError.serverError)
                    return
                }
                var model: HomeTableViewModel? = HomeTableViewModel()
                var error: NetworkingError? = NetworkingError.jsonError
                if let data = data {
                    let json = JSON(data)
                    model = try? HomeTableViewModel(json: json)
                    if model != nil {
                        error = nil
                    }
                }
                completion(model, error)
            }
            task.resume()
        }
    }
}

extension HomeTableViewModel {
    convenience init(json: JSON) throws {
        self.init()

        guard let cellsJSON = json["cells"].array else {
            throw NetworkingError.jsonError
        }

        self.items = [HomeCellItem]()

        // Initialize default items for development
        // Note: this should be empty in production
        for ItemType in HomeItemTypes.instance.getDefaultItems() {
            if let item = ItemType.getItem(for: nil) {
                items.append(item)
            }
        }

        // Initialize items from JSON
        for json in cellsJSON {
            let type = json["type"].stringValue
            let infoJSON = json["info"]
             if let ItemType = HomeItemTypes.instance.getItemType(for: type), let item = ItemType.getItem(for: infoJSON) {
                items.append(item)
            }
        }
    }
}
