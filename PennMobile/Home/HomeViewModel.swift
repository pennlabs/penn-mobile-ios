//
//  HomeViewModel.swift
//  PennMobile
//
//  Created by Anthony Li on 10/21/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//

import SwiftUI

extension Optional {
    mutating func makeNilIfError<Success, Failure: Error>() where Wrapped == Result<Success, Failure> {
        if case .some(.failure) = self {
            self = nil
        }
    }
}

@MainActor protocol HomeViewModel: ObservableObject {
    var data: HomeViewData { get }
    func fetchData(force: Bool) async throws
}

@MainActor class StandardHomeViewModel: HomeViewModel {
    static let sublettingBannerKey = "sublettingBannerDismissed"
    
    static let announceable: [HomeViewAnnounceable] = [ReservationAnnounceable()]
    
    @Published private(set) var data = HomeViewData()
    var isFetching = false
    var lastFetch: Date?
    var account: Account?
    var navigationManager: NavigationManager?
    
    init() {
        populateSublettingBannerData()
    }
    
    func clearData() {
        data = HomeViewData()
        populateSublettingBannerData()
    }
    
    func populateSublettingBannerData() {
        // data.showSublettingBanner = !UserDefaults.standard.bool(forKey: Self.sublettingBannerKey)
        data.onStartSubletting = { [weak self] in
            if let self, let navigationManager {
                let tabFeatures = UserDefaults.standard.getTabBarFeatureIdentifiers()
                if tabFeatures.contains(.subletting) {
                    navigationManager.currentTab = FeatureIdentifier.subletting.rawValue
                } else {
                    navigationManager.currentTab = "More"
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
                        navigationManager.path = .init([FeatureIdentifier.subletting])
                    }
                }
                
                data.showSublettingBanner = false
                UserDefaults.standard.set(true, forKey: Self.sublettingBannerKey)
            }
        }
        data.onDismissSubletting = { [weak self] in
            self?.data.showSublettingBanner = false
            UserDefaults.standard.set(true, forKey: Self.sublettingBannerKey)
        }
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
        data.polls.makeNilIfError()
        data.posts.makeNilIfError()
        data.newsArticles.makeNilIfError()
        data.onPollResponse = { [weak self] question, option in
            self?.respondToPoll(questionId: question, optionId: option)
        }
        
        async let announcementsTask = Task {
            
            await MainActor.run {
                self.data.announcements = []
            }
            
            _ = await StandardHomeViewModel.announceable.asyncMap { feature in
                    await feature.getHomeViewAnnouncements()
            }.flatMap({ $0 }).asyncMap { el in
                let newAnnouncement: HomeViewAnnouncement
                if let featureId = el.linkedFeature {
                    var newEl = el
                    newEl.addTapListener {
                        await MainActor.run {
                            guard let nav = self.navigationManager else { return }
                            let tabFeatures = UserDefaults.standard.getTabBarFeatureIdentifiers()
                            if tabFeatures.contains(featureId) {
                                nav.currentTab = featureId.rawValue
                            } else {
                                nav.currentTab = "More"
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                                    nav.path = .init([featureId])
                                }
                            }
                        }
                    }
                    newAnnouncement = newEl
                } else {
                    newAnnouncement = el
                }
                
                await MainActor.run {
                    self.data.announcements.append(newAnnouncement)
                }
                
                return newAnnouncement
            }
        }
        
        async let pollsTask = Task {
            let polls = await PollsNetworkManager.instance.getActivePolls().mapError { $0 as Error }
            await MainActor.run {
                data.polls = polls
            }
        }
        
        async let postsTask: () = withCheckedContinuation { continuation in
            let url = URL(string: "https://pennmobile.org/api/portal/posts/browse/")!
            Task {
                guard let request = try? await URLRequest(url: url, mode: .accessToken),
                let (data, response) = try? await URLSession.shared.data(for: request),
                let httpResponse = response as? HTTPURLResponse,
                (200..<300).contains(httpResponse.statusCode) else {
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
        
        
        _ = await announcementsTask
        async let wrappedTask = Task {
            let url = URL(string: "https://pennmobile.org/api/wrapped/semester/2025S-public/")!
            guard let req = try? await URLRequest(url: url, mode: .accessToken) else {
                DispatchQueue.main.async {
                    self.data.wrapped = .success(WrappedModel(semester: "", pages: []))
                }
                return
            }
                let task = URLSession.shared.dataTask(with: url) { data, response, _ in
                    guard let httpResponse = response as? HTTPURLResponse, let data, httpResponse.statusCode == 200 else {
                        DispatchQueue.main.async {
                            self.data.wrapped = .success(WrappedModel(semester: "", pages: []))
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        do {
                            let wrapped = try JSONDecoder().decode(WrappedModel.self, from: data)
                            self.data.wrapped = .success(wrapped)
                        } catch {
                            self.data.wrapped = .failure(error)
                        }
                    }
                }
                task.resume()
        }
        
        _ = await wrappedTask
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
