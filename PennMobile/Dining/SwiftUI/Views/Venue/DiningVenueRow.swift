//
//  DiningVenueRow.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 5/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher

struct DiningVenueRow: View {

    init(for venue: DiningVenue) {
        self.venue = venue
    }

    let venue: DiningVenue

    var body: some View {
        HStack(spacing: 13) {
            KFImage(venue.imageURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 64)
                .background(Color.grey1)
                .clipShape(RoundedRectangle(cornerRadius: 7))

            VStack(alignment: .leading, spacing: 3) {
                Label(venue.statusString, systemImage: venue.statusImageString)
                    .labelStyle(VenueStatusLabelStyle())
                    .modifier(StatusColorModifier(for: venue))

                Text(venue.name)
                    .font(.system(size: 17, weight: .medium))
                    .minimumScaleFactor(0.2)
                    .lineLimit(1)

                GeometryReader { geo in
                    ScrollView(.horizontal, showsIndicators: false) {
                        ScrollViewReader { proxy in
                            HStack(spacing: 6) {
                                ForEach(Array(venue.humanFormattedHoursArrayForToday.enumerated()), id: \.offset) { (index, time) in
                                    Text(time)
                                        .font(.system(size: 14, weight: .light, design: .default))
                                        .padding(.vertical, 3)
                                        .padding(.horizontal, 6)
                                        .foregroundColor(index == venue.currentMealIndex ? Color.white : Color.labelPrimary)
                                        .background(index == venue.currentMealIndex ? (venue.isClosingSoon ? Color.redLight : Color.greenLight) : Color.grey5)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                        .id(index)
                                        .frame(height: geo.frame(in: .global).height)
                                }.onAppear {
                                    withAnimation {
                                        proxy.scrollTo(venue.currentOrNearestMealIndex)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(height: 64)
        }
    }
}

// MARK: - ViewModifiers
struct StatusColorModifier: ViewModifier {

    init(for venue: DiningVenue) {
        self.venue = venue
    }

    let venue: DiningVenue

    func body(content: Content) -> some View {
        if venue.hasMealsToday && venue.isOpen {
            if venue.isClosingSoon {
                return content.foregroundColor(Color.red)
            } else {
                switch venue.venueType {
                case .dining:
                    if venue.isMainDiningTimes {
                        return content.foregroundColor(Color.green)
                    } else {
                        return content.foregroundColor(Color.yellow)
                    }
                default:
                    return content.foregroundColor(Color.green)
                }
            }
        } else {
            return content.foregroundColor(Color.gray)
        }
    }
}

struct VenueStatusLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon.font(.system(size: 9, weight: .semibold))
            configuration.title.font(.system(size: 11, weight: .semibold))
            Spacer()
        }
    }
}

struct DiningVenueRow_Previews: PreviewProvider {
    static var previews: some View {
        let diningVenues: DiningAPIResponse = Bundle.main.decode("sample-dining-venue.json")

        return NavigationView {
            List {
                NavigationLink(destination: Text("dfs")) {
                    DiningVenueRow(for: diningVenues.document.venues[0])
                }
                NavigationLink(destination: Text("dfs")) {
                    DiningVenueRow(for: diningVenues.document.venues[1])
                }
                NavigationLink(destination: Text("dfs")) {
                    DiningVenueRow(for: diningVenues.document.venues[2])
                }
                NavigationLink(destination: Text("dfs")) {
                    DiningVenueRow(for: diningVenues.document.venues[3])
                }
            }
        }
        .preferredColorScheme(.light)
    }
}
