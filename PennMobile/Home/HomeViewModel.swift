//
//  HomeViewModel.swift
//  PennMobile
//
//  Created by Anthony Li on 10/21/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

struct HomeViewData {
    func splashText(for date: Date) -> String {
        "Hi, Anthony!"
    }
    
    func content(for date: Date) -> some View {
        Group {
            HomeCardView {
                Text("Poll")
                    .frame(height: 200)
            }
            
            HomeCardView {
                Text("Portal Post")
                    .frame(height: 200)
            }
            
            HomeCardView {
                Text("News")
                    .frame(height: 200)
            }
            
            HomeCardView {
                Text("Events")
                    .frame(height: 200)
            }
        }
    }
}

protocol HomeViewModel: ObservableObject {
    var data: Result<HomeViewData, Error>? { get }
    func clearData()
    func fetchData() async throws
}

class MockHomeViewModel: HomeViewModel {
    @Published private(set) var data: Result<HomeViewData, Error>?
    
    private let inputData: HomeViewData
    
    init(_ data: HomeViewData) {
        self.data = nil
        inputData = data
    }
    
    func clearData() {
        data = nil
    }
    
    func fetchData() async throws {
        try await Task.sleep(for: .milliseconds(500))
        self.data = .success(inputData)
    }
}
