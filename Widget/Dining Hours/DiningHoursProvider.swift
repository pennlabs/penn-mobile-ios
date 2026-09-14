//
//  DiningHoursProvider.swift
//  DiningHoursWidgetExtension
//
//  Created by George Botros on 10/1/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//
import WidgetKit
import SwiftUI
import PennMobileShared

struct DiningEntries<Configuration>: TimelineEntry {
    var date: Date
    var venues: [DiningVenue]
    let configuration: Configuration
}

extension DiningEntries where Configuration == Void {
    init(date: Date, venues: [DiningVenue]) {
        self.init(date: date, venues: venues, configuration: ())
    }
}

/// Fetches the venues to show: the user's favorites if they have any, otherwise the defaults.
///
/// The favorite IDs come from the app (the preferences endpoint needs an access token the
/// widget doesn't have), but the hours are always freshly fetched.
private func fetchVenues() async -> [DiningVenue] {
    guard let venues = try? await DiningAPI.instance.fetchDiningHours().get() else {
        return []
    }

    let favorites = DiningAPI.venues(venues, with: DiningAPI.instance.favoriteVenueIDs)
    return favorites.isEmpty ? DiningAPI.venues(venues, with: DiningAPI.defaultVenueIds) : favorites
}

/// Downloads each venue's image to a local file, which the widget renders from.
private func withLocalImages(_ venues: [DiningVenue]) async -> [DiningVenue] {
    var venues = venues

    for (index, venue) in venues.enumerated() {
        if let imageURL = venue.image {
            if let (data, _) = try? await URLSession.shared.data(from: imageURL) {
                if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let filename = directory.appendingPathComponent(UUID().uuidString)
                    try? data.write(to: filename)
                    venues[index].localImageURL = filename
                }
            }
        }
    }

    return venues
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DiningEntries<Void> {
        DiningEntries(date: .now, venues: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (DiningEntries<Void>) -> ()) {
        Task {
            let venues = await withLocalImages(fetchVenues())
            completion(DiningEntries(date: .now, venues: venues, configuration: ()))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DiningEntries<Void>>) -> ()) {
        Task {
            let venues = await withLocalImages(fetchVenues())
            let nextDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let timeline = Timeline(entries: [DiningEntries(date: .now, venues: venues, configuration: ())], policy: .after(nextDate))
            completion(timeline)
        }
    }
}
