//
//  DiningHoursProvider.swift
//  DiningHoursWidgetExtension
//
//  Created by Christina Qiu on 10/1/24.
//  Copyright © 2023 PennLabs. All rights reserved.
//
import WidgetKit
import SwiftUI
import PennMobileShared

struct GSRLocations<Configuration>: TimelineEntry {
    var date: Date
    var gsrs: [BookedGSRs]
    let configuration: Configuration
}

extension GSRLocations where Configuration == Void {
    init(date: Date, gsrs: [BookedGSRs]) {
        self.init(date: date, gsrs: gsrs, configuration: ())
    }
}

private func getBookedGSRs() -> [BookedGSRs] {
    GSRNetworkManager.instance.getReservations { result in
        switch result {
        case .success(let reservations):
            if reservations.count > 0 {
                BookedGSRs([BookedGSRs(for: reservations)])
            } else {
                BookedGSRs([])
            }
        case .failure:
            BookedGSRs([])
        }
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> GSRLocations<Void> {
        
        GSRLocations(date: .now, gsrs: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (GSRLocations<Void>) -> ()) {
        Task {
            //let _ = await GSRNetworkManager.instance.fetchDiningHours()
            
            var gsrs: [BookedGSRs] = getBookedGSRs()
            
            if gsrs.isEmpty {
                //should put text that says u dont have anything booked
                //gsrs = GSRNetworkManager.instance.getVenues(with: DiningAPI.defaultVenueIds)
            }
            
            for (index, gsr) in gsrs.enumerated() {
                if let imageURL = gsr.image {
                    if let (data, _) = try? await URLSession.shared.data(from: imageURL) {
                        if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                            let filename = directory.appendingPathComponent(UUID().uuidString)
                            try? data.write(to: filename)
                            gsrs[index].localImageURL = filename
                        }
                    }
                }
            }
                
            let entry = GSRLocations(date: .now, gsrs: gsrs, configuration: ())
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<GSRLocations<Void>>) -> ()) {
        Task {
            //let _ = await GSRNetworkManager.instance.fetchDiningHours()
            
            var gsrs: [BookedGSRs] = getBookedGSRs()
            
            if venues.isEmpty {
                //should put text that says u dont have anything booked
                //venues = GSRNetworkManager.instance.getVenues(with: DiningAPI.defaultVenueIds)
            }
            
            for (index, gsr) in gsr.enumerated() {
                if let imageURL = venue.image {
                    if let (data, _) = try? await URLSession.shared.data(from: imageURL) {
                        if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                            let filename = directory.appendingPathComponent(UUID().uuidString)
                            try? data.write(to: filename)
                            gsrs[index].localImageURL = filename
                        }
                    }
                }
            }
            
            if let nextDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) {
                let timeline = Timeline(entries: [GSRLocations(date: .now, venues: venues, configuration: ())], policy: .after (nextDate))
                completion(timeline)
            }
        }
    }
}
