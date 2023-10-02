//
//  DiningHoursWidget.swift
//  DiningHoursWidget
//
//  Created by George Botros on 10/1/23.
//  Copyright © 2023 PennLabs. All rights reserved.
//
import WidgetKit
import SwiftUI
import PennMobileShared
import Kingfisher

struct DiningHoursWidgetEntryView : View {
    var entries: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        Group {
            switch widgetFamily {
            case .systemLarge:
                let venues = entries.venues.prefix(4)
                VStack {
                    ForEach(venues) { venue in
                        Spacer()
                        DiningVenueRow(for: venue, isWidget: true)
                        Spacer()
                    }
                }

            case .systemMedium:
                VStack {
                    let venues = entries.venues.prefix(2)
                    ForEach(venues) { venue in
                        DiningVenueRow(for: venue, isWidget: true)
                    }
                }
                
            case .systemSmall:
                let venue = entries.venues[0]
                smallWidget(venue: venue)

            default:
                Text("Unsupported")
            }
        }
    }
    
    private func smallWidget(venue: DiningVenue) -> some View {
        ZStack {
            KFImage(venue.image)
                .resizable()
                .scaledToFill()
                .background(Color.grey1)
                .overlay(
                    LinearGradient(gradient: Gradient(colors: [.clear, Color.grey6]),
                                   startPoint: .top,
                                   endPoint: .bottom)
                )
        VStack(alignment: .leading) {
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Label(venue.statusString, systemImage: venue.statusImageString)
                    .labelStyle(VenueStatusLabelStyle())
                    .modifier(StatusColorModifier(for: venue))
                    .minimumScaleFactor(0.2)
                    .lineLimit(1)
                    .padding(.leading, 10)
                
                Text(venue.name)
                    .font(.system(size: 15, weight: .medium))
                    .minimumScaleFactor(0.2)
                    .lineLimit(1)
                    .padding(.leading, 10)
                Spacer()
            }

        }
    }

}

struct VenueStatusLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon.font(.system(size: 8, weight: .semibold))
            configuration.title.font(.system(size: 10, weight: .semibold))
        }
    }
}

struct DiningHoursWidget: Widget {
    let kind: String = WidgetKind.diningHours
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                DiningHoursWidgetEntryView(entries: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                DiningHoursWidgetEntryView(entries: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Dining Hours")
        .description("Feast your eyes on feast times.")
        .contentMarginsDisabled()
        //.supportedFamilies([.systemMedium, .systemLarge])
    }
}
#Preview(as: .systemSmall) {
    DiningHoursWidget()
} timeline: {
    DiningEntries(date: .now, venues: [])
}
