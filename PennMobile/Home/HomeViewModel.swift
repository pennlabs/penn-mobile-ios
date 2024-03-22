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
    
    var polls: Result<[PollQuestion], Error>?
    var posts: Result<[Post], Error>?
    var newsArticles: Result<[NewsArticle], Error>?
    var events: [CalendarEvent] = []
    
    var onPollResponse: ((Int, Int) -> Void)?
    
    func splashText(for date: Date) -> String {
        let intro = ["Welcome", "Howdy", "Hi there", "Hello", "Greetings", "Sup"].randomElement()!
        if let firstName {
            return "\(intro), \(firstName)!"
        } else {
            return "\(intro)!"
        }
    }
    
    func sectionContent<Item, Content: View>(_ result: Result<Item, Error>?, description: LocalizedStringResource, @ViewBuilder content: (Item) -> Content) -> some View {
        return Group {
            switch result {
            case .some(.success(let item)):
                content(item)
            case .some(.failure):
                HomeCardView {
                    Text("Couldn't load \(description)")
                        .padding()
                }
            case nil:
                SwiftUI.EmptyView()
            }
        }
    }
    
    var shouldShowLoadingSpinner: Bool {
        newsArticles == nil
    }
    
    func content(for date: Date) -> some View {
        VStack(spacing: 16) {
            if shouldShowLoadingSpinner {
                ProgressView()
                    .controlSize(.large)
                    .padding(.bottom)
            }
            
            if case .some(.success(let polls)) = polls {
                ForEach(polls) { poll in
                    PollView(poll: poll, onResponse: onPollResponse.map { callback in { callback(poll.id, $0) } })
                }
            }
            
            sectionContent(posts, description: "posts") { posts in
                ForEach(posts) { post in
                    PostCardView(post: post)
                }
            }
            
            sectionContent(newsArticles, description: "article") { articles in
                ForEach(articles) { article in
                    NewsCardView(article: article)
                }
            }
            
            if !events.isEmpty {
                CalendarCardView(events: events)
            }
        }
    }
    
    static let mock = HomeViewData(
        firstName: "TEST",
        polls: .success([.mock]),
        posts: .success([
            Post(id: 1, title: "Congratulations!", subtitle: "You are our lucky winner", postUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ", imageUrl: "https://www.nps.gov/common/uploads/cropped_image/primary/D1721D51-A497-281A-72B8C06573F9327A.jpg?width=1600&quality=90&mode=crop", createdDate: Date(), startDate: Date.midnightYesterday, expireDate: Date.midnightToday, source: "Totally Legit Source")
        ]),
        newsArticles: .success([
            NewsArticle(data: .init(labsArticle: .init(slug: "a", headline: "AAAAAAAA", abstract: "AAAAAAAAAAAAAA", published_at: "1d ago", authors: [], dominantMedia: .init(imageUrl: "https://www.upenn.edu/sites/default/files/styles/default/public/2020-11/p-100297-master-v1-075a-1600x800.jpg?itok=apAkEATX", authors: []), tag: "", content: "AAAAAAAAAAAA")))
        ]),
        events: [
            .init(event: "Test Event 1", date: "October 21"),
            .init(event: "Test Event 2", date: "October 27-29 (Other University)"),
            .init(event: "Test Event With A Really Long Name", date: "Really Really Really Long Date Wow It's So Long!")
        ]
    )
    
    mutating func markPollResponse(questionId: Int, optionId: Int) {
        if case .some(.success(var polls)) = polls, let pollIndex = polls.firstIndex(where: { $0.id == questionId }) {
            var poll = polls[pollIndex]
            poll.optionChosenId = optionId
            
            if let optionIndex = poll.options.firstIndex(where: { $0.id == optionId }) {
                poll.options[optionIndex].voteCount += 1
            }
            
            polls[pollIndex] = poll
            self.polls = .success(polls)
        }
    }
}

@MainActor protocol HomeViewModel: ObservableObject {
    var data: HomeViewData { get }
    func fetchData(force: Bool) async throws
}

@MainActor class StandardHomeViewModel: HomeViewModel {
    @Published private(set) var data = HomeViewData()
    var isFetching = false
    var lastFetch: Date?
    var account: Account?
    
    func clearData() {
        data = HomeViewData()
    }
    
    func fetchData(force: Bool) async throws {
        let account = Account.getAccount()
        
        if !force {
            if isFetching {
                return
            }
            
            if let lastFetch, lastFetch.timeIntervalSinceNow > -60 * 60, account == self.account {
                return
            }
        }
        
        self.account = account
        isFetching = true
        defer { isFetching = false }
        
        print("Fetching HomeViewModel (force = \(force), isFetching = \(isFetching))")
        
        data.firstName = account?.firstName
        
        async let pollsTask = Task {
            let polls = await PollsNetworkManager.instance.getActivePolls().mapError { $0 as Error }
            await MainActor.run {
                data.polls = polls
            }
        }
        
        async let postsTask: () = withCheckedContinuation { continuation in
            OAuth2NetworkManager.instance.getAccessToken { token in
                guard let token = token else {
                    DispatchQueue.main.async {
                        self.data.posts = .success([])
                    }
                    continuation.resume()
                    return
                }

                let url = URLRequest(url: URL(string: "https://pennmobile.org/api/portal/posts/browse/")!, accessToken: token)

                let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                    guard let data = data else {
                        DispatchQueue.main.async {
                            self.data.posts = .success([])
                        }
                        continuation.resume()
                        return
                    }
                    
                    do {
                        let posts = try JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase, dateDecodingStrategy: .iso8601).decode([Post].self, from: data)
                        DispatchQueue.main.async {
                            self.data.posts = .success(posts)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.data.posts = .failure(error)
                        }
                    }
                    
                    continuation.resume()
                }

                task.resume()
            }
        }
        
        async let newsArticlesTask = Task {
            let newsArticles: Result<[NewsArticle], Error>
            
            do {
                let (data, _) = try await URLSession.shared.data(from: URL(string: "https://labs-graphql-295919.ue.r.appspot.com/graphql?query=%7BlabsArticle%7Bslug,headline,abstract,published_at,authors%7Bname%7D,dominantMedia%7BimageUrl,authors%7Bname%7D%7D,tag,content%7D%7D")!)
                
                newsArticles = try .success([JSONDecoder().decode(NewsArticle.self, from: data)])
            } catch {
                newsArticles = .failure(error)
            }
            
            await MainActor.run {
                data.newsArticles = newsArticles
            }
        }
        
        async let eventsTask: () = withCheckedContinuation { continuation in
            CalendarAPI.instance.fetchCalendar { events in
                DispatchQueue.main.async {
                    self.data.events = events ?? []
                }
                
                continuation.resume()
            }
        }
        
        _ = await pollsTask
        _ = await postsTask
        _ = await newsArticlesTask
        _ = await eventsTask
        
        lastFetch = Date()
    }
    
    func respondToPoll(questionId: Int, optionId: Int) {
        data.markPollResponse(questionId: questionId, optionId: optionId)
        Task {
            await PollsNetworkManager.instance.answerPoll(withId: PollsNetworkManager.id, response: optionId)
        }
    }
}

class MockHomeViewModel: HomeViewModel {
    @Published private(set) var data = HomeViewData.mock
    func fetchData(force: Bool) async throws {}
}
