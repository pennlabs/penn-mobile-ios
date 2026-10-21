////
////  HomeViewData.swift
////  PennMobile
////
////  Created by Jonathan Melitski on 10/16/26.
////  Copyright © 2026 PennLabs. All rights reserved.
////
//
//
////
////  HomeViewData.swift
////  PennMobile
////
////  Created by Anthony Li on 4/14/24.
////  Copyright © 2024 PennLabs. All rights reserved.
////
//
//import SwiftUI
//import PennMobileShared
//
//struct HomeViewData {
//    
//    
//    var onPollResponse: ((Int, Int) -> Void)?
//    
//    var showWellness: Bool = true
//    
//    func splashText(for firstName: String?) -> String {
//        let intro = ["Welcome", "Howdy", "Hi there", "Hello", "Greetings", "Sup"].randomElement()!
//        if let firstName {
//            return "\(intro), \(firstName)!"
//        } else {
//            return "\(intro)!"
//        }
//    }
//    
//    func content(for date: Date) -> some View {
//        VStack(spacing: 16) {
//            if shouldShowLoadingSpinner {
//                
//            }
//            
//            if case .some(.success(let wrappedData)) = self.wrapped {
//                if !wrappedData.semester.isEmpty && wrappedData.pages.count > 0 {
//                    WrappedHomeScreenExperience(with: wrappedData)
//                }
//            }
//            
//            ForEach(announcements.sorted(by: {$0.priority > $1.priority})) { announcement in
////                if let view = announcement.linkedView {
////                    NavigationLink(destination: AnyView(view)) { announcement }
////                } else {
////                    announcement
////                }
//                announcement.getBody()
//            }
//            
//            if case .some(.success(let polls)) = polls {
//                ForEach(polls) { poll in
//                    PollView(poll: poll, onResponse: onPollResponse.map { callback in { callback(poll.id, $0) } })
//                }
//            }
//            
//            sectionContent(posts, description: "posts") { posts in
//                ForEach(posts) { post in
//                    PostCardView(post: post)
//                }
//            }
//            
//            sectionContent(newsArticles, description: "news article") { articles in
//                ForEach(articles) { article in
//                    NewsCardView(article: article)
//                }
//            }
//            
//            if !events.isEmpty {
//                CalendarCardView(events: events)
//            }
//            if (showWellness) {
//                WellnessCardView()
//            }
//        }
//    }
//    
//    
//    mutating func markPollResponse(questionId: Int, optionId: Int) {
//        if case .some(.success(var polls)) = polls, let pollIndex = polls.firstIndex(where: { $0.id == questionId }) {
//            var poll = polls[pollIndex]
//            poll.optionChosenId = optionId
//            
//            if let optionIndex = poll.options.firstIndex(where: { $0.id == optionId }) {
//                poll.options[optionIndex].voteCount += 1
//            }
//            
//            polls[pollIndex] = poll
//            self.polls = .success(polls)
//        }
//    }
//}
