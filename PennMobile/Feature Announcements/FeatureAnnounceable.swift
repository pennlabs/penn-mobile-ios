//
//  FeatureAnnounceable.swift
//  PennMobile
//
//  Created by Grace Li on 2/13/26.
//  Copyright © 2026 PennLabs. All rights reserved.
//

import Foundation
import SwiftUI

struct ChangeLog: Codable {
    let cutoff: String
    let features: [NewFeature]
}

class FeatureAnnounceable: HomeViewAnnounceable {

    func getHomeViewAnnouncements() async -> [HomeViewAnnouncement] {
        let changeLog: ChangeLog? = {
            guard let url = Bundle.main.url(forResource: "ChangeLog", withExtension: "json") else {
                return nil }
            do {
                let data = try Data(contentsOf: url)
                return try JSONDecoder().decode(ChangeLog.self, from: data)
            } catch {
                assertionFailure("Failed to load ChangeLog.json: \(error)")
                return nil
            }
        }()

        guard let changeLog else {
            return []
        }

        let active = changeLog.features
            .filter { $0.version.isVersionGreaterThanOrEqual(to: changeLog.cutoff) }

        guard !active.isEmpty else {
            return []
        }
        
        let announcement = HomeViewAnnouncement(
            analyticsSlug: "feature-announcements",
            disappearOnTap: false,
            priority: .high
        ) {
            FeatureAnnouncementListView(newFeatures: active)
        }

        return [announcement]
    }
}

