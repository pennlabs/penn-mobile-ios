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
        let entry = DiningEntries(date: .now, venues: [])
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DiningEntries<Void>>) -> ()) {
        let venues: [DiningVenue] = getDiningPreferences()
        let timeline = Timeline(entries: [DiningEntries(date: .now, venues: venues, configuration: ())], policy: .atEnd)
        completion(timeline)
    }
}
