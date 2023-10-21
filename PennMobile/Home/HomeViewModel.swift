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
            
            PostCardView(post: Post(id: 1, title: "Congratulations!", subtitle: "You are our lucky winner", postUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ", imageUrl: "https://www.cnet.com/a/img/resize/2bec42558a71a3922e6e590476b919288a015288/hub/2017/06/01/a176bcb9-1442-4d6d-a7d9-f01efdbcc4bc/broken-screen-ipad-6200-002.jpg?auto=webp&fit=cropx&height=675&width=1200", createdDate: Date(), startDate: Date.midnightYesterday, expireDate: Date.midnightToday, source: "Totally Legit Source"))
            
            NewsCardView(article: NewsArticle(data: .init(labsArticle: .init(slug: "a", headline: "AAAAAAAA", abstract: "AAAAAAAAAAAAAA", published_at: "1d ago", authors: [], dominantMedia: .init(imageUrl: "https://www.upenn.edu/sites/default/files/styles/default/public/2020-11/p-100297-master-v1-075a-1600x800.jpg?itok=apAkEATX", authors: []), tag: "", content: "AAAAAAAAAAAA"))))
            
            CalendarCardView(events: [
                .init(event: "Test Event 1", date: "October 21"),
                .init(event: "Test Event 2", date: "October 27-29 (Other University)"),
                .init(event: "Test Event With A Really Long Name", date: "Really Really Really Long Date Wow It's So Long!")
            ])
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
