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
        return try Storage.retrieveThrowing(DiningAPI.favoritesCacheFileName, from: .groupCaches, as: [DiningVenue].self)
        
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
        Task {
            let _ = await DiningAPI.instance.fetchDiningHours()
            
            var venues: [DiningVenue] = getDiningPreferences()
            
            if venues.isEmpty {
                venues = DiningAPI.instance.getVenues(with: DiningAPI.defaultVenueIds)
            }
            
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
                
            let entry = DiningEntries(date: .now, venues: venues, configuration: ())
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DiningEntries<Void>>) -> ()) {
        Task {
            let _ = await DiningAPI.instance.fetchDiningHours()
            
            var venues: [DiningVenue] = getDiningPreferences()
            
            if venues.isEmpty {
                venues = DiningAPI.instance.getVenues(with: DiningAPI.defaultVenueIds)
            }
            
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
            
            if let nextDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) {
                let timeline = Timeline(entries: [DiningEntries(date: .now, venues: venues, configuration: ())], policy: .after (nextDate))
                completion(timeline)
            }
        }
    }
}
