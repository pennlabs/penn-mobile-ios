//
//  HomeView.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 10/16/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import SwiftUI
import PennMobileShared

struct HomeView: View {
    @State var vm = HomeViewModel()
    @State var showTitle = false

    var dateFormatStyle: Date.FormatStyle {
        Date.FormatStyle()
            .weekday()
            .month(.wide)
            .day()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                TimelineView(.periodic(from: Date.midnightYesterday, by: 24 * 60 * 60)) { context in
                    VStack(spacing: 0) {
                        header(for: context.date)

                        content
                            .frame(maxWidth: 480)
                            .frame(maxWidth: .infinity)

                        FeedbackCardView()
                            .padding(.vertical)

                        AttributionView()
                    }
                    .padding(.bottom)
                    // Hack for forcing the navbar to always render
                    .navigationTitle(Text(showTitle ? "\(context.date, format: dateFormatStyle)" : "\u{200C}"))
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            .refreshable {
                await vm.refresh()
            }
        }
        .task {
            await vm.refresh(force: false)
        }
    }

    func header(for date: Date) -> some View {
        VStack {
            Text("\(date, format: dateFormatStyle)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.frame(in: .global).minY
                } action: { minY in
                    showTitle = minY <= 16
                }

            Text(vm.splashText)
                .fontWeight(.medium)
                .opacity(0.7)
        }
        .offset(y: -16)
        .padding(.bottom)
        .multilineTextAlignment(.center)
    }

    var content: some View {
        VStack(spacing: 16) {
            // Only on the initial load, pull to refresh has its own indicator
            if vm.isLoading && vm.lastFetch == nil {
                ProgressView()
                    .controlSize(.large)
                    .padding(.bottom)
            }

            // Wrapped is unavailable outside of its window, so failures are not shown
            if let wrapped = vm.wrapped.unwrap(), !wrapped.semester.isEmpty && wrapped.pages.count > 0 {
//                WrappedHomeScreenExperience(with: wrapped)
            }

            ForEach(vm.sortedAnnouncements) { announcement in
                announcement.getBody()
                    .simultaneousGesture(TapGesture().onEnded {
                        vm.handleTap(on: announcement)
                    })
            }

            if let polls = vm.polls.unwrap() {
                ForEach(polls) { poll in
                    PollCardView(poll: poll) { optionId in
                        Task {
                            await vm.respondToPoll(questionId: poll.id, optionId: optionId)
                        }
                    }
                }
            }

            HomeSectionView(vm.posts, description: "posts") { posts in
                ForEach(posts) { post in
                    PostCardView(post: post)
                }
            }

            HomeSectionView(vm.newsArticle, description: "news article") { article in
                NewsCardView(article: article)
            }

            HomeSectionView(vm.events, description: "University Calendar") { events in
                if !events.isEmpty {
                    CalendarCardView(events: events)
                }
            }

            WellnessCardView()
        }
    }
}

#Preview {
    HomeView()
}
