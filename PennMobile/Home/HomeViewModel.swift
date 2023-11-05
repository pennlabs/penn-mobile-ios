//
//  HomeViewModel.swift
//  PennMobile
//
//  Created by Anthony Li on 10/21/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

struct HomeViewData {
    var firstName: String?
    
    var polls: [PollQuestion]
    var posts: [Post]
    var newsArticles: [NewsArticle]
    var events: [CalendarEvent]
    
    func splashText(for date: Date) -> String {
        let intro = ["Welcome", "Howdy", "Hi there", "Hello", "Greetings", "Sup"].randomElement()!
        if let firstName {
            return "\(intro), \(firstName)!"
        } else {
            return "\(intro)!"
        }
    }
    
    func content(for date: Date) -> some View {
        VStack(spacing: 16) {
            ForEach(polls) { poll in
                PollView(poll: poll)
            }
            
            ForEach(posts) { post in
                PostCardView(post: post)
            }
            
            ForEach(newsArticles) { article in
                NewsCardView(article: article)
            }
            
            if !events.isEmpty {
                CalendarCardView(events: events)
            }
        }
    }
    
    static let mock = HomeViewData(
        firstName: "TEST",
        polls: [.mock],
        posts: [
            Post(id: 1, title: "Congratulations!", subtitle: "You are our lucky winner", postUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ", imageUrl: "https://www.nps.gov/common/uploads/cropped_image/primary/D1721D51-A497-281A-72B8C06573F9327A.jpg?width=1600&quality=90&mode=crop", createdDate: Date(), startDate: Date.midnightYesterday, expireDate: Date.midnightToday, source: "Totally Legit Source")
        ],
        newsArticles: [
            NewsArticle(data: .init(labsArticle: .init(slug: "a", headline: "AAAAAAAA", abstract: "AAAAAAAAAAAAAA", published_at: "1d ago", authors: [], dominantMedia: .init(imageUrl: "https://www.upenn.edu/sites/default/files/styles/default/public/2020-11/p-100297-master-v1-075a-1600x800.jpg?itok=apAkEATX", authors: []), tag: "", content: "AAAAAAAAAAAA")))
        ], events: [
            .init(event: "Test Event 1", date: "October 21"),
            .init(event: "Test Event 2", date: "October 27-29 (Other University)"),
            .init(event: "Test Event With A Really Long Name", date: "Really Really Really Long Date Wow It's So Long!")
        ]
    )
}

protocol HomeViewModel: ObservableObject {
    var data: Result<HomeViewData, Error>? { get }
    func clearData()
    func fetchData(force: Bool) async throws
}

class StandardHomeViewModel: HomeViewModel {
    @Published private(set) var data: Result<HomeViewData, Error>?
    var isFetching = false
    var lastFetch: Date?
    
    func clearData() {
        data = nil
    }
    
    func fetchData(force: Bool) async throws {
        if !force {
            if isFetching {
                return
            }
            
            if case .success = data, let lastFetch, lastFetch.timeIntervalSinceNow > -60 * 60 {
                return
            }
        }
        
        isFetching = true
        defer { isFetching = false }
        
        print("Fetching HomeViewModel (force = \(force), isFetching = \(isFetching))")
        
        async let polls = (try? PollsNetworkManager.instance.getActivePolls().get()) ?? []
        
        async let posts = withCheckedThrowingContinuation { continuation in
            OAuth2NetworkManager.instance.getAccessToken { token in
                guard let token = token else { continuation.resume(returning: [Post]()); return }

                let url = URLRequest(url: URL(string: "https://pennmobile.org/api/portal/posts/browse/")!, accessToken: token)

                let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                    guard let data = data else { continuation.resume(returning: [Post]()); return }
                    
                    do {
                        let posts = try JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .iso8601).decode([Post].self, from: data)
                        continuation.resume(returning: posts)
                    } catch let error {
                        continuation.resume(throwing: error)
                    }
                }

                task.resume()
            }
        }
        
        async let newsArticles = Task {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "https://labs-graphql-295919.ue.r.appspot.com/graphql?query=%7BlabsArticle%7Bslug,headline,abstract,published_at,authors%7Bname%7D,dominantMedia%7BimageUrl,authors%7Bname%7D%7D,tag,content%7D%7D")!)
            
            return try [JSONDecoder().decode(NewsArticle.self, from: data)]
        }.value
        
        async let events = withCheckedContinuation { continuation in
            CalendarAPI.instance.fetchCalendar { events in
                continuation.resume(returning: events ?? [])
            }
        }
        
        data = .success(HomeViewData(
            firstName: Account.getAccount()?.firstName,
            polls: await polls,
            posts: (try? await posts) ?? [],
            newsArticles: (try? await newsArticles) ?? [],
            events: await events
        ))
        
        lastFetch = Date()
    }
}

class MockHomeViewModel: HomeViewModel {
    @Published private(set) var data: Result<HomeViewData, Error>?
    
    func clearData() {
        data = nil
    }
    
    func fetchData(force: Bool) async throws {
        self.data = .success(.mock)
    }
}
