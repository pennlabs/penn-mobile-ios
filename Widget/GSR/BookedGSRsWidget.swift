//
//  DiningHoursWidget.swift
//  DiningHoursWidget
//
//  Created by Christina Qiu on 10/1/24.
//  Copyright © 2023 PennLabs. All rights reserved.
//
import WidgetKit
import SwiftUI
import PennMobileShared
import Kingfisher

struct BookedGSRsWidgetEntryView : View {
    var entries: Provider.Entry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        Group {
            switch widgetFamily {
            case .systemLarge:
                VStack {
                    let gsrs = entries.gsrs.prefix(4)
                    ForEach(gsrs) { gsr in
                        Spacer()
                        HomeReservationsCellItem(for: gsr)
                        Spacer()
                    }
                }.padding()

            case .systemMedium:
                VStack {
                    let gsrs = entries.gsrs.prefix(2)
                    ForEach(gsrs) { gsr in
                        HomeReservationsCellItem(for: gsr)
                    }
                }.padding()
                
            case .systemSmall:
                let gsrs = entries.gsrs.prefix(1)
                ForEach(gsrs) { gsr in
                    smallWidget(gsr: gsr)
                }
            
            default:
                Text("Unsupported")
            }
        }
    }
    
    private func smallWidget(venue: BookedGSR) -> some View {
        ZStack () {
            
            if let localImageURL = gsr.localImageURL, let uiImage = UIImage(contentsOfFile: localImageURL.path) {
                GeometryReader { geo in
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .background(Color.grey1)
                        .overlay(
                            LinearGradient(gradient: Gradient(colors: [.clear, Color.grey6]),
                                           startPoint: .top,
                                           endPoint: .bottom)
                        )
                }
            }
            HStack {
                VStack (alignment: .leading) {
                    Spacer()
                    Label(gsr.statusString, systemImage: gsr.statusImageString)
                        .labelStyle(VenueStatusLabelStyle())
                        //.modifier(StatusColorModifier(for: venue))
                        .minimumScaleFactor(0.2)
                        .lineLimit(1)
                        .padding(.leading, 20)
                        .padding(.trailing, 5)
                    
                    Text(venue.name)
                        .font(.system(size: 15, weight: .medium))
                        .minimumScaleFactor(0.2)
                        .lineLimit(1)
                        .padding(.leading, 20)
                        .padding(.trailing, 5)
                }
                .padding(.bottom, 10)
                
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

struct BookedGSRsWidget: Widget {
    let kind: String = WidgetKind.BookedGSRs
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                BookedGSRsWidgetEntryView(entries: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                BookedGSRsWidgetEntryView(entries: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Booked GSRs")
        .description("Feast your eyes on feast times.")
        .contentMarginsDisabled()
    }
}

@available(iOS 17.0, *)
#Preview(as: .systemSmall) {
    BookedGSRsWidget()
} timeline: {
    GSRLocations(date: .now, venues: [])
}
