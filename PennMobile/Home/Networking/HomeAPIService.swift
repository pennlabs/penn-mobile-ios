//
//  HomeAPIService.swift
//  PennMobile
//
//  Created by Josh Doman on 1/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

class HomeAPIService {
    
    static let instance = HomeAPIService()
    
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
                operation = LaundryAPIOperation(rooms: item.rooms)
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
