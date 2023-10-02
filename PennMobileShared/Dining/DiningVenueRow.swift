//
//  DiningVenueRow.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 5/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI
import Kingfisher

public struct DiningVenueRow: View {
    
    let venue: DiningVenue
    let isWidget: Bool

    public init(for venue: DiningVenue, isWidget: Bool = false) {
        self.venue = venue
        self.isWidget = isWidget
    }

    public var body: some View {
        HStack(spacing: 13) {
            KFImage(venue.image)
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
                    // Ensure widget view is static
                    if (!isWidget) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            ScrollViewReader { proxy in
                                hoursDisplay(in: geo, fontSize: 14, horizontalPadding: 6)
                                    .onAppear {
                                        withAnimation {
                                            proxy.scrollTo(venue.currentOrNearestMealIndex)
                                        }
                                    }
                            }
                        }
                    } else {
                        hoursDisplay(in: geo, fontSize: 10.5, horizontalPadding: 4)
                        // Vertical pipe separator view
//                        Text(venue.humanFormattedHoursStringForToday)
//                            .font(.system(size: 12, weight: .light, design: .default))
//                            .foregroundColor(Color.gray)
//                            .scaledToFit()
//                            .minimumScaleFactor(0.01)
//                            .lineLimit(1)
                    }
                }
            }
            .frame(height: 64)
        }
    }
    
    private func hoursDisplay(in geo: GeometryProxy, fontSize: CGFloat, horizontalPadding: CGFloat) -> some View {
        HStack(spacing: 4) {
            ForEach(Array(venue.humanFormattedHoursArrayForToday.enumerated()), id: \.offset) { (index, time) in
                Text(time)
                    .font(.system(size: fontSize, weight: .light, design: .default))
                    .padding(.vertical, 3)
                    .padding(.horizontal, horizontalPadding)
                    .foregroundColor(index == venue.currentMealIndex ? Color.white : Color.labelPrimary)
                    .background(index == venue.currentMealIndex ? (venue.isClosingSoon ? Color.redLight : Color.greenLight) : Color.grey5)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .id(index)
                    .frame(height: geo.frame(in: .global).height)
            }
        }
    }
}

// MARK: - ViewModifiers
public struct StatusColorModifier: ViewModifier {

    public init(for venue: DiningVenue) {
        self.venue = venue
    }

    let venue: DiningVenue

    public func body(content: Content) -> some View {
        if venue.hasMealsToday && venue.isOpen {
            if venue.isClosingSoon {
                return content.foregroundColor(Color.red)
            } else {
                return content.foregroundColor(Color.green)
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
