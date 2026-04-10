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
            if isWidget {
                if let localImageURL = venue.localImageURL, let uiImage = UIImage(contentsOfFile: localImageURL.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 64)
                        .background(Color.grey1)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                }
            } else {
                KFImage(venue.image)
                    .setProcessor(
                            DownsamplingImageProcessor(size: CGSize(width: 200, height: 128)))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 64)
                    .background(Color.grey1)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
            }
 
            TimelineView(.everyMinute) { _ in
                VStack(alignment: .leading, spacing: 3) {
                    let status = venue.currentStatus()
                    Label(venue.statusText(), systemImage: status.iconString)
                        .labelStyle(VenueStatusLabelStyle())
                        .foregroundStyle(status.labelColor)

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
                                                proxy.scrollTo(venue.currentStatus().relevantMeal)
                                            }
                                        }
                                }
                            }
                        } else {
                            hoursDisplay(in: geo, fontSize: 10.5, horizontalPadding: 4)
                        }
                    }
                }
                .frame(height: 64)
            }
        }
    }
    
    @ViewBuilder
    private func hoursDisplay(in geo: GeometryProxy, fontSize: CGFloat, horizontalPadding: CGFloat) -> some View {
        HStack(spacing: 4) {
            ForEach(venue.mealsToday(), id: \.self) { meal in
                let isActive = venue.currentStatus().relevantMeal == meal
                Text(meal.getHumanReadableHours())
                    .font(.system(size: fontSize, weight: .light, design: .default))
                    .padding(.vertical, 3)
                    .padding(.horizontal, horizontalPadding)
                    .foregroundColor(isActive ? venue.currentStatus().textColor : Color.primary)
                    .background(isActive ? venue.currentStatus().bgColor : .grey6)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .id(meal)
                    .frame(height: geo.frame(in: .global).height)
            }
        }
    }
}

// MARK: - ViewModifiers

public struct VenueStatusLabelStyle: LabelStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon.font(.system(size: 9, weight: .semibold))
            configuration.title.font(.system(size: 11, weight: .semibold))
            Spacer()
        }
    }
}
