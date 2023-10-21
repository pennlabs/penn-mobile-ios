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
    
    // TODO: Replace with actual poll data
    var hasPoll: Bool
    
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
        Group {
            if hasPoll {
                HomeCardView {
                    Text("Poll")
                        .frame(height: 200)
                }
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
        hasPoll: true,
        posts: [
            Post(id: 1, title: "Congratulations!", subtitle: "You are our lucky winner", postUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ", imageUrl: "https://images.pexels.com/photos/5380603/pexels-photo-5380603.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2", createdDate: Date(), startDate: Date.midnightYesterday, expireDate: Date.midnightToday, source: "Totally Legit Source")
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
    func fetchData() async throws
}

class StandardHomeViewModel: HomeViewModel {
    @Published private(set) var data: Result<HomeViewData, Error>?
    
    func clearData() {
        data = nil
    }
    
    func fetchData() async throws {
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
            hasPoll: false,
            posts: (try? await posts) ?? [],
            newsArticles: (try? await newsArticles) ?? [],
            events: await events
        ))
    }
}

class MockHomeViewModel: HomeViewModel {
    @Published private(set) var data: Result<HomeViewData, Error>?
    
    func clearData() {
        data = nil
    }
    
    func fetchData() async throws {
        self.data = .success(.mock)
    }
}
