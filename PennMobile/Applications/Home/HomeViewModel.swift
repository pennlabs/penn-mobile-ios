//
//  HomeViewModel.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 10/16/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

@MainActor
@Observable
class HomeViewModel {
    static let announceables: [HomeViewAnnounceable] = [
        ReservationAnnounceable()
    ]

    var polls: BackendFetchedResult<[PollQuestion]> = .pending
    var posts: BackendFetchedResult<[Post]> = .pending
    var announcements: [HomeViewAnnouncement] = []
    var newsArticle: BackendFetchedResult<NewsArticle> = .pending
    var wrapped: BackendFetchedResult<WrappedModel> = .pending
    var events: BackendFetchedResult<[CalendarEvent]> = .pending

    var firstName: String?
    private let splashIntro = ["Welcome", "Howdy", "Hi there", "Hello", "Greetings", "Sup"].randomElement()!

    var isLoading = false
    private(set) var lastFetch: Date?

    var splashText: String {
        if let firstName {
            return "\(splashIntro), \(firstName)!"
        }
        return "\(splashIntro)!"
    }

    var sortedAnnouncements: [HomeViewAnnouncement] {
        announcements.sorted { $0.priority > $1.priority }
    }

    init() {}

    // Unforced refreshes are skipped if one is in flight or the last one was within the hour
    func refresh(force: Bool = true) async {
        if !force {
            if isLoading { return }
            if let lastFetch, lastFetch.timeIntervalSinceNow > -60 * 60 { return }
        }

        isLoading = true
        await withTaskGroup(of: Void.self) { group in
            group.addTask { @MainActor in
                var announcements = [HomeViewAnnouncement]()
                for announceable in Self.announceables {
                    announcements += await announceable.getHomeViewAnnouncements()
                }
                self.announcements = announcements
            }
            group.addTask { @MainActor in
                self.polls = await PennMobileApplication.Polls.GetActivePolls().execute(shouldSilentlyFail: true)
            }
            group.addTask { @MainActor in
                self.posts = await PennMobileApplication.Posts.GetPosts().execute(shouldSilentlyFail: true)
            }
            group.addTask { @MainActor in
                self.newsArticle = await PennMobileApplication.News.GetLabsArticle().execute(shouldSilentlyFail: true)
            }
            group.addTask { @MainActor in
                self.wrapped = await PennMobileApplication.Wrapped.GetWrappedSemester(semester: "2025S-public").execute(shouldSilentlyFail: true)
            }
            group.addTask { @MainActor in
                self.events = await PennMobileApplication.Events.GetCalendar().execute(shouldSilentlyFail: true)
            }
        }
        isLoading = false
        lastFetch = Date()
    }

    // Optimistically marks the vote locally, the endpoint's toast surfaces any failure
    func respondToPoll(questionId: Int, optionId: Int) async {
        guard case .success(var polls) = polls,
              let pollIndex = polls.firstIndex(where: { $0.id == questionId }) else { return }

        polls[pollIndex].optionChosenId = optionId
        if let optionIndex = polls[pollIndex].options.firstIndex(where: { $0.id == optionId }) {
            polls[pollIndex].options[optionIndex].voteCount += 1
        }
        withAnimation {
            self.polls = .success(polls)
        }

        await PennMobileApplication.Polls.AnswerPoll(optionId: optionId).execute()
    }

    func handleTap(on announcement: HomeViewAnnouncement) {
        Task {
            for listener in announcement.onTap {
                await listener()
            }
        }

        if announcement.disappearOnTap {
            withAnimation {
                announcements.removeAll { $0.id == announcement.id }
            }
        }
    }
}
