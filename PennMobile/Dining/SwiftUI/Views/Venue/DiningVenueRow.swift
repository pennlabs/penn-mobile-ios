//
//  DiningVenueRow.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 5/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
import KingfisherSwiftUI
#endif

@available(iOS 13, *)
struct DiningVenueRow: View {
    
    init(for venue: DiningVenue) {
        self.venue = venue
    }
    
    let venue: DiningVenue
    
    var body: some View {
        HStack(spacing: 17) {
            
            KFImage(venue.imageURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 63.98)
                .background(Color.grey1)
                .clipShape(RoundedRectangle(cornerRadius: 7))
                
            VStack(alignment: .leading, spacing: 0) {
                
                HStack(spacing: 5) {
                    Image(systemName: circleImageString)
                        .font(.system(size: 10))
                    
                    Text(statusString)
                        .font(.system(size: 11, weight: .semibold))
                }
                .statusColorModifier(for: venue)
                
                
                Text(venue.name)
                    .font(.system(size: 17, weight: .medium))
                    .minimumScaleFactor(0.2)
                    .lineLimit(1)
                
                Spacer()
                
                FadingScrollView(fadeDistance: fadeDistance, .horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(0..<venue.humanFormattedHoursArrayForToday.count) { index in
                            Text("\(self.venue.humanFormattedHoursArrayForToday[index])")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor((self.venue.currentMealIndex == index) ? Color.white : Color.grey1)
                                .padding(5)
                                .background((self.venue.currentMealIndex == index) ? (self.venue.isMainDiningTimes ? Color.green : Color.yellow) : Color.grey6)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
                .offset(x: -fadeDistance)
            }
            .frame(height: 63.98)
        }
    }
    
    var fadeDistance: CGFloat = 10
    
    var circleImageString: String {
        if venue.hasMealsToday {
            if venue.isOpen {
                return "circle.fill"
            } else if venue.nextMeal != nil {
                return "pause.circle.fill"
            } else {
                return "xmark.circle.fill"
            }
        } else {
            return "xmark.circle.fill"
        }
    }
    
    var statusString: String {
        if venue.hasMealsToday {
            if venue.isOpen {
                if venue.isClosingSoon {
                    return "Closes \(venue.timeLeft)"
                } else {
                    switch venue.venueType {
                    case .dining:
                        return venue.currentMealType!
                    default:
                        return "Open"
                    }
                    
                }
            } else if let nextMeal = venue.nextMeal {
                switch venue.venueType {
                case .dining:
                    return "\(nextMeal.type) \(Date().humanReadableDistanceFrom(nextMeal.open))"
                default:
                    return "Opens \(Date().humanReadableDistanceFrom(nextMeal.open))"
                }
            } else {
                return "Closed \(venue.nextOpenedDayOfTheWeek)"
            }
        } else {
            return "Closed \(venue.nextOpenedDayOfTheWeek)"
        }
    }
}

// MARK: - ViewModifiers
@available(iOS 13, *)
struct StatusColorModifier: ViewModifier {
    var venue: DiningVenue
    
    func body(content: Content) -> some View {
        if venue.hasMealsToday {
            if venue.isOpen {
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
        } else {
            return content.foregroundColor(Color.gray)
        }
    }
}

@available(iOS 13, *)
extension View {
    func statusColorModifier(for venue: DiningVenue) -> some View {
        self.modifier(StatusColorModifier(venue: venue))
  }
}

@available(iOS 13, *)
struct DiningVenueRow_Previews: PreviewProvider {
    static var previews: some View {
        let diningVenues: DiningAPIResponse = Bundle.main.decode("sample-dining-venue.json")
        
        return NavigationView {
            List {
                DiningVenueRow(for: diningVenues.document.venues[0])
                DiningVenueRow(for: diningVenues.document.venues[1])
                NavigationLink(destination: Text("dfs")) {
                    DiningVenueRow(for: diningVenues.document.venues[13])
                }
            }
        }
    }
}


