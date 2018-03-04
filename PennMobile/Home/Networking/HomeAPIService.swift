//
//  HomeAPIService.swift
//  PennMobile
//
//  Created by Josh Doman on 1/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

protocol HomeAPIRequestable where Self: HomeViewModelItem {
    func fetchData(_ completion: @escaping () -> Void)
}

class HomeAPIService: Requestable {
    
    static let instance = HomeAPIService()
    
    typealias APICompletion = (_ item: HomeViewModelItem) -> Void
    
    func fetchModel(_ completion: @escaping (HomeViewModel?) -> Void) {
        let url = "https://api.pennlabs.org/homepage"
        getRequest(url: url) { (dict) in
            var model: HomeViewModel? = nil
            if let dict = dict {
                let json = JSON(dict)
                model = try? HomeViewModel(json: json)
            }
            completion(model)
        }
    }
    
    func fetchData(for items: [HomeViewModelItem], singleCompletion: @escaping APICompletion, finished: @escaping () -> Void) {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 3
        
        let finishedOperation = BlockOperation {
            finished()
        }
        
        for item in items {
            guard let requestableItem = item as? HomeAPIRequestable else { continue }
            let operation = HomeAPIOperation(item: requestableItem, completion: singleCompletion)
            finishedOperation.addDependency(operation)
            operationQueue.addOperation(operation)
        }
        
        OperationQueue.main.addOperation(finishedOperation)
    }
    
    // MARK: - HomeAPIOperation
    private class HomeAPIOperation: AsynchronousOperation {
        private let item: HomeAPIRequestable
        private let completion: APICompletion
        
        init(item: HomeAPIRequestable, completion: @escaping APICompletion) {
            self.item = item
            self.completion = completion
        }
        
        override func main() {
            super.main()
            item.fetchData {
                self.completion(self.item as! HomeViewModelItem)
                self.state = .finished
            }
        }
    }
}

extension HomeViewModelItemType {
    fileprivate static func parseJSON(_ json: JSON) throws -> [HomeViewModelItemType] {
        guard let cellsJSON = json["cells"].array else {
            throw NetworkingError.jsonError
        }
        return cellsJSON.map { HomeViewModelItemType(rawValue: $0["type"].stringValue) }
                        .filter { $0 != nil }
                        .map { $0! }
    }
}

extension HomeViewModelDiningItem: HomeAPIRequestable {
    func fetchData(_ completion: @escaping () -> Void) {
        DiningAPI.instance.fetchDiningHours { _ in
            completion()
        }
    }
}

extension HomeViewModelLaundryItem: HomeAPIRequestable {    
    func fetchData(_ completion: @escaping () -> Void) {
        LaundryNotificationCenter.shared.updateForExpiredNotifications {
            LaundryAPIService.instance.fetchLaundryData(for: [self.room]) { (rooms) in
                if let room = rooms?.first {
                    self.room = room
                }
                completion()
            }
        }
    }
}

extension HomeViewModel {
    convenience init(json: JSON) throws {
        self.init()
        
        guard let cellsJSON = json["cells"].array else {
            throw NetworkingError.jsonError
        }
        
        self.items = [HomeViewModelItem]()
        for json in cellsJSON {
            guard let type = HomeViewModelItemType(rawValue: json["type"].stringValue) else { continue }
            let infoJSON = json["info"]
            let item = try HomeViewModel.generateItem(for: type, infoJSON: infoJSON)
            items.append(item)
        }
    }
    
    static func generateItem(for type: HomeViewModelItemType, infoJSON: JSON? = nil) throws -> HomeViewModelItem {
        switch type {
        case .event:
            let imageUrl = infoJSON?["imageUrl"].string ?? ""
            return HomeViewModelEventItem(imageUrl: imageUrl)
        case .dining:
            if let json = infoJSON {
                return try HomeViewModelDiningItem(json: json)
            } else {
                let venues = DiningVenue.getDefaultVenues()
                return HomeViewModelDiningItem(venues: venues)
            }
        case .laundry:
            if let json = infoJSON {
                return try HomeViewModelLaundryItem(json: json)
            } else {
                let room = LaundryRoom.getDefaultRooms().first!
                return HomeViewModelLaundryItem(room: room)
            }
        case .studyRoomBooking:
            return HomeViewModelStudyRoomItem()
        }
    }
}

extension HomeViewModelDiningItem {
    convenience init(json: JSON) throws {
        guard let ids = json["venues"].arrayObject as? [Int] else {
            throw NetworkingError.jsonError
        }
        var venues: [DiningVenue] = try ids.map { try DiningVenue(id: $0) }
        if venues.isEmpty {
            venues = DiningVenue.getDefaultVenues()
        }
        self.init(venues: venues)
    }
}

extension HomeViewModelLaundryItem {
    convenience init(json: JSON) throws {
        let id = json["room_id"].intValue
        let room: LaundryRoom
        if let laundryRoom = LaundryAPIService.instance.idToRooms?[id] {
            room = laundryRoom
        } else {
            room = LaundryRoom.getPreferences().first!
        }
        self.init(room: room)
    }
}

