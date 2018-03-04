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
