//
//  HomeAsynchronousFetching.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

protocol HomeAPIRequestable where Self: HomeCellItem {
    func fetchData(_ completion: @escaping () -> Void)
}

final class HomeAsynchronousAPIFetching {
    static let instance = HomeAsynchronousAPIFetching()
    private init() {}
    
    typealias APICompletion = (_ item: HomeCellItem) -> Void
    
    /**
    * Single completion: executes as soon as an item has finished fetching from the API
    * Finished: executes once all items have finished fetching the data that they need
    **/
    func fetchData(for items: [HomeCellItem], singleCompletion: @escaping APICompletion, finished: @escaping () -> Void) {
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
                self.completion(self.item as HomeCellItem)
                self.state = .finished
            }
        }
    }
}
