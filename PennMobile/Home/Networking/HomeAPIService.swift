//
//  HomeAPIService.swift
//  PennMobile
//
//  Created by Josh Doman on 1/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

class HomeAPIService: Requestable {
    
    static let instance = HomeAPIService()
    
    func fetchModel(_ completion: @escaping (HomeViewModel?) -> Void) {
        let url = "http://api-dev.pennlabs.org/homepage"
        getRequest(url: url) { (dict) in
            var model: HomeViewModel? = nil
            if let dict = dict {
                let json = JSON(dict)
                model = try? HomeViewModel(json: json)
            }
            completion(model)
        }
    }
    
    func fetchData(for items: [HomeViewModelItem], _ completion: @escaping () -> Void) {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 3
        
        let completionOperation = BlockOperation {
            completion()
        }
        
        for item in items {
            var operation: Operation!
            switch item.type {
            case .dining:
                operation = DiningAPIOperation()
            case .laundry:
                guard let item = item as? HomeViewModelLaundryItem else { break }
                operation = LaundryAPIOperation(rooms: [item.room])
            default:
                break
            }
            guard operation != nil else { continue }
            completionOperation.addDependency(operation)
            operationQueue.addOperation(operation)
        }
        
        OperationQueue.main.addOperation(completionOperation)
    }
    
    // MARK: - DiningAPIOperation
    private class DiningAPIOperation: AsynchronousOperation {
        override func main() {
            super.main()
            DiningAPI.instance.fetchDiningHours { (_) in
                self.state = .finished
            }
        }
    }
    
    // MARK: - LaundryAPIOperation
    private class LaundryAPIOperation: AsynchronousOperation {
        private let rooms: [LaundryRoom]
        
        init(rooms: [LaundryRoom]) {
            self.rooms = rooms
            super.init()
        }
        
        override func main() {
            super.main()
            LaundryAPIService.instance.fetchLaundryData(for: rooms, withUsageData: false) { (_) in
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
