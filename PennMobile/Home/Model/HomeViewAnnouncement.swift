//
//  HomeViewAnnouncement.swift
//  PennMobile
//
//  Created by Jonathan Melitski on 2/19/25.
//  Copyright © 2025 PennLabs. All rights reserved.
//
import SwiftUI

struct HomeViewAnnouncement:  Identifiable {
    let id = UUID()
    let content: any View
    let linkedView: (any View)?
    let linkedFeature: FeatureIdentifier?
    let priority: AnnouncementPriority
    // For analytics
    let slug: String
    let disappearOnTap: Bool
    var onTap: [() -> Void] = []
    @State var show = true
    
    init(analyticsSlug: String, disappearOnTap: Bool, priority: AnnouncementPriority = .medium, @ViewBuilder _ content: () -> any View, @ViewBuilder linkedView: () -> any View) {
        self.content = content()
        self.linkedView = linkedView()
        self.priority = priority
        self.slug = analyticsSlug
        self.disappearOnTap = disappearOnTap
        self.linkedFeature = nil
    }
    
    init(analyticsSlug: String, disappearOnTap: Bool, priority: AnnouncementPriority = .medium, linkedFeature: FeatureIdentifier, @ViewBuilder _ content: () -> any View) {
        self.content = content()
        self.linkedFeature = linkedFeature
        self.priority = priority
        self.slug = analyticsSlug
        self.disappearOnTap = disappearOnTap
        self.linkedView = nil
    }
    
    @ViewBuilder
    func getBody() -> (some View) {
            HomeCardView {
                if show {
                    if let view = linkedView {
                        NavigationLink(destination: AnyView(view)) {
                            AnyView(content)
                        }
                    } else {
                        AnyView(content)
                    }
                }
            }
            .onTapGesture {
                onTap.forEach {
                    $0()
                }
                if disappearOnTap {
                    withAnimation {
                        show = false
                    }
                }
            }
    }
    
//    func getBody() -> some View {
////        if let view = linkedView  {
////            return
////                NavigationLink(destination: AnyView(view)) {
////                    getAnnouncementContent()
////                }
////        } else {
////            return getAnnouncementContent()
////        }
//        return getAnnouncementContent()
//
//    }
    
    mutating func addTapListener(_ listener: @escaping () -> Void) {
        onTap.append(listener)
    }
    
    enum AnnouncementError: Error {
        case noLinkedView
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
