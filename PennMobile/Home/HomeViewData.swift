//
//  HomeViewData.swift
//  PennMobile
//
//  Created by Anthony Li on 4/14/24.
//  Copyright © 2024 PennLabs. All rights reserved.
//

import SwiftUI

struct HomeViewData {
    var firstName: String?
    
    var showSublettingBanner: Bool = false
    
    var polls: Result<[PollQuestion], Error>?
    var posts: Result<[Post], Error>?
    var newsArticles: Result<[NewsArticle], Error>?
    var wrapped: Result<WrappedModel, Error>?
    var events: [CalendarEvent] = []
    
    var onPollResponse: ((Int, Int) -> Void)?
    var onStartSubletting: (() -> Void)?
    var onDismissSubletting: (() -> Void)?
    
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
            case .some(.failure(let error)):
                HomeCardView {
                    VStack {
                        Image(systemName: "pc")
                            .font(.system(size: 60))
                            .symbolRenderingMode(.multicolor)
                            .padding(.bottom, 4)
                        Text("Couldn't load \(description) :(")
                            .fontWeight(.bold)
                        Text(error.localizedDescription)
                            .font(.caption)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 24)
                }
                .multilineTextAlignment(.center)
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
            
            if case .some(.success(let wrappedData)) = self.wrapped {
                if let pages = wrappedData.pages, pages.count > 0 {
                    WrappedHomeScreenExperience(with: wrappedData)
                }
            }
            
             if showSublettingBanner {
                HomeSublettingBanner {
                    onStartSubletting?()
                } onDismiss: {
                    onDismissSubletting?()
                }
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
            
            sectionContent(newsArticles, description: "news article") { articles in
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
        showSublettingBanner: true,
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
