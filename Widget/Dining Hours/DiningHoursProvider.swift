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

private func getDiningPreferences() -> [DiningVenue] {
    do {
        return try Storage.retrieveThrowing(DiningAPI.cacheFileName, from: .groupCaches, as: [DiningVenue].self)
        
    } catch let error {
        print("Couldn't load dining preferences: \(error)")
        return []
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DiningEntries<Void> {
        DiningEntries(date: .now, venues: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DiningEntries<Void>) -> ()) {
        let entry = DiningEntries(date: .now, venues: DiningAPI.instance.getVenues(with: DiningAPI.defaultVenueIds))
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DiningEntries<Void>>) -> ()) {
        var venues: [DiningVenue] = getDiningPreferences()

        let dispatchGroup = DispatchGroup()

            for (index, venue) in venues.enumerated() {
                dispatchGroup.enter()
                if let imageURL = venue.image {
                    let task = URLSession.shared.dataTask(with: imageURL) { (data, _, _) in
                        if let data = data, let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                            let filename = directory.appendingPathComponent(UUID().uuidString)
                            try? data.write(to: filename)
                            venues[index].localImageURL = filename
                        }
                        dispatchGroup.leave()
                    }
                    task.resume()
                } else {
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                if let nextDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) {
                    let timeline = Timeline(entries: [DiningEntries(date: .now, venues: venues, configuration: ())], policy: .after (nextDate))
                    completion(timeline)
                }
            }
    }
}
