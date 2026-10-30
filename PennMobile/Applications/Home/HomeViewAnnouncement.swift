//
//  HomeViewAnnouncement.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 2/19/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//
import SwiftUI

struct HomeViewAnnouncement: Identifiable {
    let id = UUID()
    let content: any View
    let linkedView: (any View)?
    let linkedFeature: FeatureIdentifier?
    let priority: AnnouncementPriority
    // For analytics
    let slug: String?
    // Dismissal is handled by HomeViewModel.handleTap(on:)
    let disappearOnTap: Bool
    var onTap: [() async -> Void] = []
    
    init(analyticsSlug: String?, disappearOnTap: Bool, priority: AnnouncementPriority = .medium, @ViewBuilder _ content: () -> any View, @ViewBuilder linkedView: () -> any View) {
        self.content = content()
        self.linkedView = linkedView()
        self.priority = priority
        self.slug = analyticsSlug
        self.disappearOnTap = disappearOnTap
        self.linkedFeature = nil
    }
    
    init(analyticsSlug: String?, disappearOnTap: Bool, priority: AnnouncementPriority = .medium, linkedFeature: FeatureIdentifier, @ViewBuilder _ content: () -> any View) {
        self.content = content()
        self.linkedFeature = linkedFeature
        self.priority = priority
        self.slug = analyticsSlug
        self.disappearOnTap = disappearOnTap
        self.linkedView = nil
    }
    
    init(analyticsSlug: String?, disappearOnTap: Bool, priority: AnnouncementPriority = .medium, @ViewBuilder _ content: () -> any View) {
        self.content = content()
        self.linkedFeature = nil
        self.linkedView = nil
        self.priority = priority
        self.slug = analyticsSlug
        self.disappearOnTap = disappearOnTap
    }
    
    @ViewBuilder
    func getBody() -> some View {
        HomeCardView {
            if let view = linkedView {
                NavigationLink(destination: AnyView(view)) {
                    AnyView(content)
                }
                .buttonStyle(.plain)
            } else if let featureId = linkedFeature,
                      let appFeature = features.first(where: { $0.id == featureId }) {
                NavigationLink(destination: appFeature.content) {
                    AnyView(content)
                }
                .buttonStyle(.plain)
            } else {
                AnyView(content)
            }
        }
    }
    
    mutating func addTapListener(_ listener: @escaping () async -> Void) {
        onTap.append(listener)
    }
}

enum AnnouncementPriority: Int, Comparable {
    static func < (lhs: AnnouncementPriority, rhs: AnnouncementPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    case urgent = 3
    case high = 2
    case medium = 1
    case low = 0
}
